cwlVersion: v1.2
class: Workflow
id: sentieon_tnseq
label: Sentieon TNseq somatic Workflow
requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement
$namespaces:
  sbg: https://sevenbridges.com
inputs:
  sentieon_license:
    label: Sentieon license
    doc: License server host and port
    type: string
  indexed_reference_fasta:
    type: File
    doc: Reference fasta and fai index
    secondaryFiles:
    - pattern: .fai
      required: true
    - pattern: ^.dict
      required: false
    sbg:suggestedValue:
      class: File
      path: 60639014357c3a53540ca7a3
      name: Homo_sapiens_assembly38.fasta
      secondaryFiles:
      - class: File
        path: 60639016357c3a53540ca7af
        name: Homo_sapiens_assembly38.fasta.fai
      - class: File
        path: 60639019357c3a53540ca7e7
        name: Homo_sapiens_assembly38.dict
    sbg:fileTypes: FASTA, FA
  input_tumor_aligned:
    type: File
    secondaryFiles:
    - pattern: .bai
      required: false
    - pattern: ^.bai
      required: false
    - pattern: .crai
      required: false
    - pattern: ^.crai
      required: false
    doc: BAM/SAM/CRAM file containing tumor reads
    sbg:fileTypes: BAM, CRAM, SAM
  input_normal_aligned:
    type: File?
    secondaryFiles:
    - pattern: .bai
      required: false
    - pattern: ^.bai
      required: false
    - pattern: .crai
      required: false
    - pattern: ^.crai
      required: false
    doc: BAM/SAM/CRAM file containing normal reads
    sbg:fileTypes: BAM, CRAM, SAM
  panel_of_normals:
    type: File?
    secondaryFiles:
    - pattern: .idx
      required: false
    - pattern: .tbi
      required: false
    - pattern: .csi
      required: false
    sbg:fileTypes: VCF, VCF.GZ
  af_only_gnomad_vcf:
    type: File
    secondaryFiles: 
    - pattern: .tbi
      required: true
    sbg:suggestedValue:
      class: File
      path: 5f50018fe4b054958bc8d2e3
      name: af-only-gnomad.hg38.vcf.gz
      secondaryFiles:
      - class: File
        path: 5f50018fe4b054958bc8d2e5
        name: af-only-gnomad.hg38.vcf.gz.tbi
    sbg:fileTypes: VCF, VCF.GZ
  exac_common_vcf:
    type: File?
    secondaryFiles: 
    - pattern: .tbi
      required: true
    doc: |-
      Exac Common VCF (and index) used for calculating contamination values used in filtering
      the VCF. If do not wish to perfom this filtering, remove this input.
    sbg:suggestedValue:
      class: File
      path: 5f500135e4b0370371c051ad
      name: small_exac_common_3.hg38.vcf.gz
      secondaryFiles: 
      - class: File
        path: 5f500135e4b0370371c051af
        name: small_exac_common_3.hg38.vcf.gz.tbi
    sbg:fileTypes: VCF, VCF.GZ
  interval:
    type: File?
    label: Interval
    doc: |-
      An option for interval in the reference that will be used in the software.
    sbg:fileTypes: BED, VCF, interval_list

  input_tumor_name:
    type: string
    doc: BAM sample name of tumor
  input_normal_name:
    type: string?
    doc: BAM sample name of normal(s), if any.
  run_orientation_bias_mixture_model_filter:
     type: boolean?
     default: true
     doc: Should Orientation Bias Mixture Model Filter be applied to the outputs
  output_basename:
    type: string
    doc: String to use as the base for output filenames


outputs:
  filtered_vcf:
    type: File
    outputSource: run_tnfilter/output_vcf
    doc: VCF with SNV, MNV, and INDEL variant calls
    secondaryFiles:
    - pattern: .tbi
      required: true
  tnhap2_stats:
    type: File
    outputSource: run_tnhap2/stats_file
  tnfilter_stats:
    type: File
    outputSource: run_tnfilter/stats_file

steps:
  run_tnhap2:
    run: ../tools/TNseq/sentieon_TNhaplotyper2.cwl
    in:
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      input_bam:
        source: [input_tumor_aligned, input_normal_aligned]
      interval: interval
      tumor_sample: input_tumor_name
      normal_sample: input_normal_name
      germline_vcf: af_only_gnomad_vcf
      pon: panel_of_normals
      output_file_name: 
        source: output_basename
        valueFrom: |
          $(self).vcf.gz
    out: [output_vcf, stats_file]
  run_orientationbias:
    run: ../tools/TNseq/sentieon_OrientationBias.cwl
    when: |
      $(inputs.enable_tool ? true : false)
    in:
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      input_bam:
        source: [input_tumor_aligned, input_normal_aligned]
      interval: interval
      tumor_sample: input_tumor_name
      output_file_name: output_basename
      enable_tool: run_orientation_bias_mixture_model_filter
    out: [out_orient]
  run_contaminationmodel:
    run: ../tools/TNseq/sentieon_ContaminationModel.cwl
    when: |
      $(inputs.vcf != null)
    in:  
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      input_bam:
        source: [input_tumor_aligned, input_normal_aligned]
      interval: interval
      tumor_sample: input_tumor_name
      normal_sample: input_normal_name
      vcf: exac_common_vcf
      output_file_name: output_basename
    out: [output_contamination, tumor_segments]
  run_tnfilter:
    run: ../tools/TNseq/sentieon_TNfilter.cwl
    in:
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      input_vcf: run_tnhap2/output_vcf
      tumor_sample: input_tumor_name
      normal_sample: input_normal_name
      contamination: run_contaminationmodel/output_contamination
      tumor_segments: run_contaminationmodel/tumor_segments
      orientation_priors: run_orientationbias/out_orient
      output_file_name: 
        source: output_basename
        valueFrom: |
          $(self).filtered.vcf.gz
    out: [output_vcf, stats_file]