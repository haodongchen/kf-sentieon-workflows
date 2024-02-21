cwlVersion: v1.2
class: Workflow
id: sentieon_germline
label: Sentieon Long Read Germline Workflow
doc: |-
  Sentieon DNAscope is able to take advantage of the long read length of PacBio HiFi and ONT reads to perform quick and accurate variant calling using specially calibrated machine learning models.
requirements:
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement
inputs:
  sentieon_license:
    label: Sentieon license
    doc: License server host and port
    type: string
  input_reads:
    type: File[]
    doc: "Input fastq reads"
  input_rg:
    type: string
    doc: "RG string"
  indexed_reference_fasta: 
    type: File
    doc: "Reference fasta and fai index."
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
  output_basename:
    type: string
    doc: "String to use as the base for output filenames"
  dbsnp_vcf:
    type: File?
    doc: "dbSNP vcf file"
    secondaryFiles: 
    - pattern: .idx
      required: false
    - pattern: .tbi
      required: false
    - pattern: .csi
      required: false
    sbg:suggestedValue: 
      class: File
      path: 6063901f357c3a53540ca84b
      name: Homo_sapiens_assembly38.dbsnp138.vcf
      secondaryFiles:
      - class: File
        path: 6063901e357c3a53540ca834
        name: Homo_sapiens_assembly38.dbsnp138.vcf.idx
  target_intervals:
    type: File?
  platform:
    doc: "DNAscope model selection"
    type:
      - type: enum
        symbols:
          - PacBio_HiFi
          - Oxford_Nanopore
outputs:
  aligned_reads: 
    type: File?
    outputSource: sentieon_minimap2/out_alignments
    doc: "(Re)Aligned Reads File"
    secondaryFiles:
    - pattern: .bai
      required: true
    - pattern: .crai
      required: false
  vcf:
    type: File[]?
    outputSource: generate_vcf/output_vcf
    secondaryFiles:
      pattern: .tbi
      required: true
  sv_vcf:
    type: File?
    outputSource: longread_sv/output_vcf
    secondaryFiles:
      pattern: .tbi
      required: true
steps:
  download_model_file:
    run: ../tools/download_DNAscope_model.cwl
    in:
      model_name: 
        source: platform
        valueFrom: |-
          $(self)-WGS
    out: [model_bundle]
  sentieon_minimap2:
    run: ../tools/sentieon_minimap2.cwl
    in:
      sentieon_license: sentieon_license
      reference: indexed_reference_fasta
      in_reads: input_reads
      read_group_line: input_rg
      model_bundle: download_model_file/model_bundle
      output_name: output_basename
    out: [out_alignments]
  generate_vcf:
    run: ../tools/sentieon_DNAscope_LongRead.cwl
    in:
      sentieon_license: sentieon_license
      platform:
        source: platform
        valueFrom: |-
          ${
              if (self === "PacBio_HiFi") {
                return "HiFi"
              }
              else if (self === "Oxford_Nanopore") {
                return "ONT"
              }
          }
      model_bundle: download_model_file/model_bundle
      reference: indexed_reference_fasta
      input_bam: sentieon_minimap2/out_alignments
      bed: target_intervals
      dbSNP: dbsnp_vcf
      output_gvcf: 
        valueFrom: ${return Boolean(true)}
      output_file_name:
        source: output_basename
        valueFrom: $(self).vcf.gz 
    out: [output_vcf]
  longread_sv:
    run: ../tools/sentieon_LongReadSV.cwl
    in:
      sentieon_license: sentieon_license
      model_bundle: download_model_file/model_bundle
      reference: indexed_reference_fasta
      input_bam: sentieon_minimap2/out_alignments
      output_file_name:
        source: output_basename
        valueFrom: $(self).sv.vcf.gz
    out: [output_vcf]
$namespaces:
  sbg: https://sevenbridges.com
