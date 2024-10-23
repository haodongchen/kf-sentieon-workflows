cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_DNAscope_LongRead
$namespaces:
  sbg: https://sevenbridges.com
requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMin: |-
      ${
          if (inputs.cpu_per_job)
          {
              return inputs.cpu_per_job
          }
          else
          {
              return 32
          }
      }
    ramMin: |-
      ${
          if (inputs.mem_per_job)
          {
              return inputs.mem_per_job
          }
          else
          {
              return 60000
          }
      }
  DockerRequirement:
    dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202308.03
  EnvVarRequirement:
    envDef:
    - envName: SENTIEON_LICENSE
      envValue: $(inputs.sentieon_license)
  InlineJavascriptRequirement: {}

inputs:
  reference:
    type: File
    doc: "Fasta for reference genome"
    inputBinding:
      position: 1
      prefix: -r
    secondaryFiles:
    - pattern: .fai
      required: true
    - pattern: ^.dict
      required: false
  fastq:
    type: File[]?
    doc: "Sample fastq files"
    inputBinding:
      position: 2
      prefix: --fastq
  readgroups:
    type: string[]?
    doc: "Readgroup information for the fastq files"
    inputBinding:
      position: 3
      prefix: --readgroups
  input_bam:
    type: File[]?
    doc: "sample BAM or CRAM file"
    inputBinding:
      position: 4
      prefix: -i
    secondaryFiles:
    - pattern: ^.bai
      required: false
    - pattern: ^.crai
      required: false
    - pattern: .bai
      required: false
    - pattern: .crai
      required: false
  align:
    type: boolean?
    default: false
    inputBinding:
      position: 5
      prefix: --align
  model_bundle:
    type: File
    doc: "The model bundle file"
    inputBinding:
      position: 6
      prefix: -m
  tech:
    type: string?
    doc: "{HiFi,ONT}     Sequencing technology used to generate the reads. (default: 'HiFi')"
    inputBinding:
      position: 7
      prefix: --tech
  dbsnp:
    type: File?
    doc: "dbSNP vcf file Supplying this file will annotate variants with their dbSNP refSNP ID numbers."
    inputBinding:
      position: 8
      prefix: -d
    secondaryFiles:
    - pattern: .tbi
      required: false
    - pattern: .idx
      required: false
  diploid_bed:
    type: File?
    doc: "Region BED file. Supplying this file will limit variant calling to the intervals inside the BED file."
    inputBinding:
      position: 9
      prefix: -b
  haploid_bed:
    type: File?
    inputBinding:
      position: 10
      prefix: --haploid-bed
  gvcf:
    type: boolean?
    default: false
    inputBinding:
      position: 11
      prefix: --gvcf
  bam_format:
    type: boolean?
    default: false
    doc: "Use the BAM format instead of CRAM for output aligned files (default: False)"
    inputBinding:
      position: 12
      prefix: --bam_format
  cores:
    type: int?
    doc: "Number of threads/processes to use"
    inputBinding:
      position: 13
      prefix: -t
  skip-small-variants:
    type: boolean?
    default: false
    doc: "Skip small variant (SNV/indel) calling (default: False)"
    inputBinding:
      position: 14
      prefix: --skip-small-variants
  skip-svs:
    type: boolean?
    default: false
    doc: "Skip SV calling (default: False)"
    inputBinding:
      position: 15
      prefix: --skip-svs
  skip-mosdepth:
    type: boolean?
    default: false
    doc: "Skip QC with mosdepth (default: False)"
    inputBinding:
      position: 16
      prefix: --skip-mosdepth
  input_ref:
    type: File?
    doc: "Used to decode the input alignment file. Required if the input file is in the CRAM/uCRAM formats"
    inputBinding:
      position: 17
      prefix: --input_ref
    secondaryFiles:
    - pattern: .fai
      required: true
  fastq_taglist:
    type: string?
    doc: "A comma-separated list of tags to retain. Defaults to ''*'' and the 'RG' tag is required"
    inputBinding:
      position: 18
      prefix: --fastq_taglist
  minimap2_args:
    type: string?
    doc: "Extra arguments for sentieon minimap2 (default: '-Y')"
    inputBinding:
      position: 20
      prefix: --minimap2_args
  util_sort_args:
    type: string?
    doc: "Extra arguments for sentieon util sort (default: '--cram_write_options version=3.0,compressor=rans')"
    inputBinding:
      position: 21
      prefix: --util_sort_args
  output_vcf:
    type: string
    doc: "Output VCF File. The file name must end in .vcf.gz"
    inputBinding:
      position: 100
  sentieon_license:
    label: Sentieon license
    doc: License server host and port
    type: string
  cpu_per_job:
    label: CPU per job
    doc: CPU per job
    type: int?
  mem_per_job:
    label: Memory per job
    doc: Memory per job[MB].
    type: int?

outputs:
  vcf:
    type: File[]
    secondaryFiles:
    - pattern: .tbi
      required: true
    outputBinding:
      glob: '*.vcf.gz'
    sbg:fileTypes: VCF.GZ
  cram:
    type: File[]?
    secondaryFiles:
    - pattern: .bai
      required: false
    - pattern: .crai
      required: false
    outputBinding:
      glob: ["*.cram", "*.bam"]
  mosdepth_out:
    type: File[]?
    outputBinding:
      glob: '*_mosdepth_*'

baseCommand:
- sentieon-cli
- dnascope-longread
