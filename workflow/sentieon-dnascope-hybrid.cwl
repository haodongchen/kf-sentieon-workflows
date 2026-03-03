cwlVersion: v1.2
class: Workflow
id: sentieon-dnascope-hybrid-workflow
label: Sentieon DNAscope Hybrid Short+Long Read Variant Calling Workflow
doc: |
  Workflow for running the Sentieon DNAscope Hybrid pipeline, which jointly analyzes
  short-read and long-read sequencing data to call SNVs, indels, structural variants,
  and copy-number variants.

  The pipeline supports two input modes:
  - **Aligned input**: Provide pre-aligned BAM/CRAM files via sr_aln and lr_aln
  - **Unaligned input**: Provide FASTQ files for short reads (sr_r1_fastq, sr_r2_fastq,
    sr_readgroups) and uBAM/uCRAM for long reads (lr_aln + lr_align_input flag)

  The pipeline produces:
  1. SNV/indel VCF - Small variant calls from joint short+long read analysis
  2. SV VCF - Structural variant calls from Sentieon LongReadSV
  3. CNV VCF - Copy-number variant calls from Sentieon CNVscope
  4. Deduplicated short-read alignment (FASTQ input only)
  5. Sorted long-read alignment (unaligned input only)
  6. QC metrics directory with MultiQC report

  ## References
  - Sentieon DNAscope Hybrid: https://support.sentieon.com/docs/sentieon_cli/#dnascope-hybrid

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  # Required inputs
  reference:
    type: File
    secondaryFiles:
      - .fai?
      - .amb?
      - .ann?
      - .bwt?
      - .pac?
      - .sa?
      - ^.dict?
      - .dict?
    doc: GRCh38 reference genome FASTA with samtools and BWA indices

  model_bundle:
    type: File
    doc: Platform-specific model bundle file

  output_vcf_name:
    type: string
    doc: Output VCF file name (must end in .vcf.gz)

  sentieon_license:
    type: string
    doc: License server host and port

  # Input data - aligned (BAM/CRAM)
  sr_aln:
    type: File[]?
    secondaryFiles:
      - .bai?
      - .crai?
      - ^.bai?
      - ^.crai?
    doc: Short-read input BAM or CRAM alignment file(s); alternative to sr_r1_fastq/sr_r2_fastq

  lr_aln:
    type: File[]?
    secondaryFiles:
      - .bai?
      - .crai?
      - ^.bai?
      - ^.crai?
    doc: Long-read input BAM, CRAM, uBAM, or uCRAM file(s); use with lr_align_input for unaligned reads

  # Input data - unaligned short reads (FASTQ)
  sr_r1_fastq:
    type: File[]?
    doc: Short-read R1 FASTQ file(s) (gzip compressed); alternative to sr_aln

  sr_r2_fastq:
    type: File[]?
    doc: Short-read R2 FASTQ file(s) (gzip compressed)

  sr_readgroups:
    type: string[]?
    doc: |
      Read group strings for short-read FASTQ input; count must match sr_r1_fastq
      (e.g., "@RG\tID:sample-1\tSM:sample\tLB:sample-LB\tPL:ILLUMINA")

  # Long-read alignment options
  lr_align_input:
    type: boolean?
    doc: Align the input long-read BAM/CRAM/uBAM/uCRAM file to the reference genome

  lr_input_ref:
    type: File?
    doc: Reference FASTA for decoding long-read CRAM or uCRAM input files

  # Optional inputs
  bed_file:
    type: File?
    doc: BED file to restrict diploid variant calling to specified intervals

  dbsnp:
    type: File?
    secondaryFiles:
      - .tbi
    doc: dbSNP VCF file (bgzip compressed and indexed) for variant annotation with rsIDs

  pop_vcf:
    type: File?
    secondaryFiles:
      - .tbi
    doc: Population VCF with allele frequency annotations for use with DNAModelApply

  gvcf:
    type: boolean?
    doc: Generate a gVCF output file in addition to the VCF

  bam_format:
    type: boolean?
    doc: Use BAM format instead of CRAM for output aligned files

  sr_duplicate_marking:
    type:
      - "null"
      - type: enum
        symbols:
          - markdup
          - rmdup
          - none
    doc: Short-read duplicate marking mode; one of markdup (default), rmdup, or none

  rgsm:
    type: string?
    doc: Overwrite the SM tag of all input readgroups for sample name compatibility

  skip_cnv:
    type: boolean?
    doc: Skip CNV calling

  skip_svs:
    type: boolean?
    doc: Skip SV calling

  skip_metrics:
    type: boolean?
    doc: Skip all metrics collection and multiQC report

  skip_mosdepth:
    type: boolean?
    doc: Skip QC with mosdepth

  skip_multiqc:
    type: boolean?
    doc: Skip multiQC report generation

outputs:
  output_vcf:
    type: File
    outputSource: sentieon_dnascope_hybrid/output_vcf
    doc: SNV and indel variant calls in VCF format

  output_gvcf:
    type: File?
    outputSource: sentieon_dnascope_hybrid/output_gvcf
    doc: gVCF output file (only produced when gvcf is set)

  sv_vcf:
    type: File?
    outputSource: sentieon_dnascope_hybrid/sv_vcf
    doc: Structural variant calls from Sentieon LongReadSV

  cnv_vcf:
    type: File?
    outputSource: sentieon_dnascope_hybrid/cnv_vcf
    doc: Copy-number variant calls from Sentieon CNVscope

  sr_deduped:
    type: File?
    outputSource: sentieon_dnascope_hybrid/sr_deduped
    doc: Aligned, deduplicated short reads (only produced from FASTQ input)

  lr_sorted:
    type: File[]?
    outputSource: sentieon_dnascope_hybrid/lr_sorted
    doc: Sorted long-read alignment file(s) lifted to reference (only produced when lr_align_input is set)

  metrics_dir:
    type: Directory?
    outputSource: sentieon_dnascope_hybrid/metrics_dir
    doc: QC metrics directory with MultiQC report

steps:

  sentieon_dnascope_hybrid:
    run: ../tools/sentieon-cli-dnascope-hybrid.cwl
    in:
      reference: reference
      sr_aln: sr_aln
      lr_aln: lr_aln
      model_bundle: model_bundle
      sr_r1_fastq: sr_r1_fastq
      sr_r2_fastq: sr_r2_fastq
      sr_readgroups: sr_readgroups
      lr_align_input: lr_align_input
      lr_input_ref: lr_input_ref
      bed_file: bed_file
      dbsnp: dbsnp
      pop_vcf: pop_vcf
      gvcf: gvcf
      bam_format: bam_format
      sr_duplicate_marking: sr_duplicate_marking
      rgsm: rgsm
      skip_cnv: skip_cnv
      skip_svs: skip_svs
      skip_metrics: skip_metrics
      skip_mosdepth: skip_mosdepth
      skip_multiqc: skip_multiqc
      output_vcf_name: output_vcf_name
      sentieon_license: sentieon_license
    out: [output_vcf, output_gvcf, sv_vcf, cnv_vcf, sr_deduped, lr_sorted, metrics_dir]

$namespaces:
  sbg: https://sevenbridges.com
