cwlVersion: v1.2
class: Workflow
id: sentieon_germline
label: Sentieon DNAscope Germline Workflow
doc: |-
  Sentieon germline workflows support alignment (with FASTQ input), preprocessing, and germline variant calling using either the Sentieon Haplotyper or Sentieon DNAscope variant callers. Variant calling with DNAscope can utilize DNAscope model files for Illumina, Element Biosciences, Ultima Genomics, and MGI/Complete Genomics to correct platform-specific data biases, further improving variant calling accuracy. Variant calls can be output in either the VCF format for a single-sample callset or the gVCF format for later integration through joint calling.
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
  input_pe_reads:
    type: File
    doc: "Input R1 paired end fastq reads"
  input_pe_mates:
    type: File?
    doc: "Input R2 paired end fastq reads"
  input_pe_rg:
    type: string
    doc: "RG string"
  reference_tar:
    type: File
    doc: |-
      Tar file containing a reference fasta and, optionally, its complete set of associated indexes (samtools, bwa, and picard)
    sbg:suggestedValue:
      class: File
      path: 5f4ffff4e4b0370371c05153
      name: Homo_sapiens_assembly38.tgz
  output_basename:
    type: string
    doc: "String to use as the base for output filenames"
  dbsnp_vcf:
    type: File?
    doc: "dbSNP vcf file"
    sbg:suggestedValue: 
      class: File
      path: 6063901f357c3a53540ca84b
      name: Homo_sapiens_assembly38.dbsnp138.vcf
  dbsnp_idx:
    type: File?
    doc: "dbSNP vcf index file"
    sbg:suggestedValue:
      class: File
      path: 6063901e357c3a53540ca834
      name: Homo_sapiens_assembly38.dbsnp138.vcf.idx
  target_intervals:
    type: File?
  is_pcr_free:
    default: false
    type: boolean
    doc: Set to true if the library is PCR-free
  dnascope_model:
    doc: "DNAscope model selection"
    type:
      - "null"
      - type: enum
        symbols:
          - Illumina-WGS
          - Illumina-WES
          - MGI-WGS
          - MGI-WES
          - Element_Biosciences-WGS
outputs:
  aligned_reads: 
    type: File?
    outputSource: sentieon_markdups/out_alignments
    doc: "(Re)Aligned Reads File"
    secondaryFiles:
    - pattern: .bai
      required: true
    - pattern: .crai
      required: false
  gvcf:
    type: File?
    outputSource: generate_gvcf/output_vcf
    doc: "Genomic VCF generated from the realigned alignment file."
    secondaryFiles:
      pattern: .tbi
      required: true
steps:
  untar_reference:
    run: ../tools/untar_indexed_reference_2.cwl
    in:
      reference_tar: reference_tar
    out: [indexed_fasta, dict]
  download_model_file:
    run: ../tools/download_DNAscope_model.cwl
    in:
      model_name: 
        source: dnascope_model
        valueFrom: |
          $(self)
    out: [model_bundle]
  sentieon_bwa_mem:
    run: ../tools/sentieon_bwa_sort.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      reads_forward: input_pe_reads
      reads_mate: input_pe_mates
      rg: input_pe_rg
      model_bundle: download_model_file/model_bundle
    out: [output]
  sentieon_markdups:
    run: ../tools/sentieon_dedup.cwl
    in:
      sentieon_license: sentieon_license
      reference: untar_reference/indexed_fasta
      in_alignments: 
        source: sentieon_bwa_mem/output
        valueFrom: |
          $(self ? [self] : self)
      prefix: output_basename
    out: [metrics_file, out_alignments]
  index_dbsnp:
    run:
      class: CommandLineTool
      requirements:
        InitialWorkDirRequirement:
          listing:
            - $(inputs.dbsnp_vcf)
            - $(inputs.dbsnp_idx)
      inputs:
        dbsnp_vcf:
          type: File?
        dbsnp_idx:
          type: File?
      outputs:
        output:
          type: File
          secondaryFiles: [.idx]
          outputBinding:
            glob: '*.vcf'
    in:
      dbsnp_vcf: dbsnp_vcf
      dbsnp_idx: dbsnp_idx
    out: [output]
  generate_gvcf:
    run: ../tools/sentieon_DNAscope.cwl
    in:
      sentieon_license: sentieon_license
      input_bam: sentieon_markdups/out_alignments
      reference: untar_reference/indexed_fasta
      interval: target_intervals
      dbSNP: index_dbsnp/output
      model_bundle: download_model_file/model_bundle
      is_pcr_free: is_pcr_free
      emit_mode: 
        valueFrom: "gvcf"
      output_file_name:
        source: output_basename
        valueFrom: $(self).g.vcf.gz 
    out: [output_vcf]
$namespaces:
  sbg: https://sevenbridges.com
