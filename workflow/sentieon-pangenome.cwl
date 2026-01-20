cwlVersion: v1.2
class: Workflow
id: sentieon-pangenome-workflow
label: Sentieon Pangenome Alignment and Variant Calling Workflow
doc: |
  Workflow for running the Sentieon pangenome pipeline. This pipeline processes genomic reads through
  graph-based structures to enhance alignment and variant calling accuracy.

  The pipeline executes these steps:
  1. K-mer spectrum extraction - Generates KFF file from input reads
  2. Personalized pangenome generation - Creates sample-specific pangenome
  3. Read mapping to reference - Aligns FASTQ reads to FASTA reference (skipped for BAM/CRAM input)
  4. Personalized reference alignment - Maps reads to personalized reference, then lifts back to standard reference
  5. Duplicate marking and QC - Identifies duplicate molecules and generates quality metrics
  6. Variant calling - Uses DNAscope to identify SNVs and indels with genotype calculations

  ## Limitations
  - **Pangenome format**: Only supports **GRCh38** Minigraph-Cactus pangenomes with UCSC-style contig names (`chr1`, `chr2`, etc.)
  - **Supported pangenomes**: Designed for Human Pangenome Reference Consortium (HPRC) pangenomes
  - **Species**: Specifically designed and validated for human samples only
  - **Alternative formats**: Contact Sentieon support for guidance on using different pangenome types

  ## References
  - Sentieon pangenome: https://support.sentieon.com/docs/Pangenome_usage/pangenome/

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

  hapl_file:
    type: File
    doc: Pangenome hapl file (https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.hapl)

  gbz_file:
    type: File
    doc: Pangenome GBZ file (https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-grch38.gbz)

  model_bundle:
    type: File
    doc: Platform-specific model bundle file

  pop_vcf:
    type: File
    secondaryFiles:
      - .tbi
    doc: Population VCF with allele frequency data (https://ftp.sentieon.com/public/GRCh38/population/pop-v20g41-20251216.vcf.gz)

  output_vcf_name:
    type: string
    doc: Output VCF file name (must end in .vcf.gz)

  # Input data (FASTQ or BAM/CRAM)
  r1_fastq:
    type: File[]?
    doc: Read 1 FASTQ file(s) (gzip compressed)

  r2_fastq:
    type: File[]?
    doc: Read 2 FASTQ file(s) (gzip compressed)

  readgroup:
    type: string?
    doc: Read group string for FASTQ input (e.g., "@RG\tID:sample-1\tSM:sample\tLB:sample-LB\tPL:ILLUMINA")

  sample_input:
    type: File[]?
    secondaryFiles:
      - .bai?
      - .crai?
      - ^.bai?
      - ^.crai?
    doc: Input BAM or CRAM alignment file(s) (alternative to FASTQ input)

  # Optional inputs
  bed_file:
    type: File?
    doc: BED file for calling intervals; if not provided, will download hg38_canonical.bed from Sentieon FTP

  dbsnp:
    type: File?
    secondaryFiles:
      - .tbi
    doc: dbSNP VCF file (bgzip compressed and indexed)

  pcr_free:
    type: boolean?
    doc: Apply PCR-free library prep priors for INDEL variant detection

  bam_format:
    type: boolean?
    doc: Use BAM format instead of CRAM for output aligned files

  skip_metrics:
    type: boolean?
    doc: Skip metrics collection and multiQC report

  skip_multiqc:
    type: boolean?
    doc: Skip multiQC report generation

  sentieon_license:
    type: string
    doc: License server host and port

outputs:
  output_vcf:
    type: File
    outputSource: sentieon_pangenome/output_vcf
    doc: Variant calls in VCF format

  bwa_cram:
    type: File
    outputSource: sentieon_pangenome/bwa_cram
    doc: BWA-aligned, deduplicated reads

  mm2_cram:
    type: File
    outputSource: sentieon_pangenome/mm2_cram
    doc: Minimap2-aligned (pangenome), deduplicated reads lifted to GRCh38

  metrics_dir:
    type: Directory?
    outputSource: sentieon_pangenome/metrics_dir
    doc: QC metrics directory

steps:

  sentieon_pangenome:
    run: ../tools/sentieon-cli-pangenome.cwl
    in:
      reference: reference
      hapl_file: hapl_file
      gbz_file: gbz_file
      model_bundle: model_bundle
      pop_vcf: pop_vcf
      r1_fastq: r1_fastq
      r2_fastq: r2_fastq
      readgroup: readgroup
      sample_input: sample_input
      bed_file: bed_file
      dbsnp: dbsnp
      pcr_free: pcr_free
      bam_format: bam_format
      skip_metrics: skip_metrics
      skip_multiqc: skip_multiqc
      output_vcf_name: output_vcf_name
      sentieon_license: sentieon_license
    out: [output_vcf, bwa_cram, mm2_cram, metrics_dir]

$namespaces:
  sbg: https://sevenbridges.com
