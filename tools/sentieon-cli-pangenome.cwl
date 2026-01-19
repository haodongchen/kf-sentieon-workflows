cwlVersion: v1.2
class: CommandLineTool
id: sentieon_cli_pangenome
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202503.02
  - class: ResourceRequirement
    coresMin: $(inputs.cpu ? inputs.cpu : 64)
    ramMin: $(inputs.ram ? inputs.ram*1000 : 110000)
  - class: EnvVarRequirement
    envDef:
    - envName: SENTIEON_LICENSE
      envValue: $(inputs.sentieon_license)
baseCommand: ["sentieon-cli", "sentieon-pangenome"]

inputs:
  reference:
    type: File
    inputBinding:
      prefix: -r
      position: 1
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
    inputBinding:
      prefix: --hapl
      position: 2
    doc: Pangenome hapl file (e.g., hprc-v2.0-mc-grch38.hapl)

  gbz_file:
    type: File
    inputBinding:
      prefix: --gbz
      position: 3
    doc: Pangenome GBZ file (e.g., hprc-v2.0-mc-grch38.gbz)

  model_bundle:
    type: File
    inputBinding:
      prefix: -m
      position: 4
    doc: Platform-specific model bundle file

  pop_vcf:
    type: File
    inputBinding:
      prefix: --pop_vcf
      position: 5
    doc: Population VCF with allele frequency data (bgzip compressed and indexed)

  r1_fastq:
    type: File[]?
    inputBinding:
      prefix: --r1_fastq
      position: 6
    doc: Read 1 FASTQ file(s) (gzip compressed)

  r2_fastq:
    type: File[]?
    inputBinding:
      prefix: --r2_fastq
      position: 7
    doc: Read 2 FASTQ file(s) (gzip compressed)

  readgroup:
    type: string?
    inputBinding:
      prefix: --readgroup
      position: 8
    doc: Read group string for FASTQ input (e.g., "@RG\tID:sample-1\tSM:sample\tLB:sample-LB\tPL:ILLUMINA")

  sample_input:
    type: File[]?
    inputBinding:
      prefix: -i
      position: 9
    secondaryFiles:
      - .bai?
      - .crai?
      - ^.bai?
      - ^.crai?
    doc: Input BAM or CRAM alignment file(s) (alternative to FASTQ input)

  bed_file:
    type: File?
    inputBinding:
      prefix: -b
      position: 10
    doc: BED file for calling intervals

  dbsnp:
    type: File?
    inputBinding:
      prefix: -d
      position: 11
    secondaryFiles:
      - .tbi
    doc: dbSNP VCF file (bgzip compressed and indexed)

  pcr_free:
    type: boolean?
    inputBinding:
      prefix: --pcr_free
      position: 13
    doc: Apply PCR-free library prep priors for INDEL variant detection

  bam_format:
    type: boolean?
    inputBinding:
      prefix: --bam_format
      position: 14
    doc: Use BAM format instead of CRAM for output aligned files

  skip_metrics:
    type: boolean?
    inputBinding:
      prefix: --skip_metrics
      position: 16
    doc: Skip metrics collection and multiQC report

  skip_multiqc:
    type: boolean?
    inputBinding:
      prefix: --skip_multiqc
      position: 17
    doc: Skip multiQC report generation

  output_vcf_name:
    type: string
    inputBinding:
      position: 99
    doc: Output VCF file name (must end in .vcf.gz)

  sentieon_license:
    type: string
    doc: License server host and port

  cpu:
    type: 'int?'
    default: 64
    doc: "Number of CPUs to allocate to this task."

  ram:
    type: 'int?'
    default: 110
    doc: "GB size of RAM to allocate to this task."
	
arguments: []

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf_name)
    secondaryFiles:
      - .tbi
    doc: Variant calls in VCF format

  bwa_cram:
    type: File
    outputBinding:
      glob: |
        ${
          var base = inputs.output_vcf_name.replace(/\.vcf\.gz$/, '');
          var ext = inputs.bam_format ? '.bam' : '.cram';
          return base + '_bwa_deduped' + ext;
        }
    secondaryFiles:
      - .bai?
      - .crai?
    doc: BWA-aligned, deduplicated reads

  mm2_cram:
    type: File
    outputBinding:
      glob: |
        ${
          var base = inputs.output_vcf_name.replace(/\.vcf\.gz$/, '');
          var ext = inputs.bam_format ? '.bam' : '.cram';
          return base + '_mm2_deduped' + ext;
        }
    secondaryFiles:
      - .bai?
      - .crai?
    doc: Minimap2-aligned (pangenome), deduplicated reads lifted to GRCh38

  metrics_dir:
    type: Directory?
    outputBinding:
      glob: |
        ${
          var base = inputs.output_vcf_name.replace(/\.vcf\.gz$/, '');
          return base + '_metrics';
        }
    doc: QC metrics directory
