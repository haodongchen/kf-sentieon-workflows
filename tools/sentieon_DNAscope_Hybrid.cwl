cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_hybrid
doc: |-
  Sentieon DNAscope hybrid is a pipeline for germline variant calling from combined short-read and
  long-read data from a single sample. The DNAscope hybrid pipeline is able to utilize the strengths
  of both technologies to generate variant callsets that are more accurate than either short-read or
  long-read data alone.
  The pipeline supports input data in the following formats:
  * Unaligned short-read data in gzipped FASTQ format.
  * Aligned short-reads in BAM or CRAM format.
  * Unaligned long-read data in the uBAM or uCRAM format.
  * Aligned long-read data in BAM or CRAM format.

  By default, the pipeline will generate the following output files:
  * Small variants (SNVs andindels) in the VCF format.
  * Structural variants in the VCF format.
  * Copy-number variants in the VCF format.

  If unaligned reads are used as input, the pipeline will also output aligned reads in BAM or CRAM format.
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: LoadListingRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if (inputs.cpu_per_job)
        {
            return inputs.cpu_per_job
        }
        else
        {
            return 36
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
            return 71000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202503.01.rc1
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: reference
  doc: Fasta for reference genome
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: false
  - pattern: .64.amb
    required: false
  - pattern: .64.ann
    required: false
  - pattern: .64.bwt
    required: false
  - pattern: .64.pac
    required: false
  - pattern: .64.sa
    required: false
  - pattern: .64.alt
    required: false
  - pattern: .amb
    required: false
  - pattern: .ann
    required: false
  - pattern: .bwt
    required: false
  - pattern: .pac
    required: false
  - pattern: .sa
    required: false
  - pattern: .alt
    required: false
  inputBinding:
    prefix: -r
    position: 10
    shellQuote: true
  sbg:fileTypes: FA, FASTA
- id: sr_r1_fastq
  doc: Short-read R1 fastq files
  type: File[]?
  inputBinding:
    prefix: --sr_r1_fastq
    position: 12
    shellQuote: true
- id: sr_r2_fastq
  doc: Short-read R2 fastq files
  type: File[]?
  inputBinding:
    prefix: --sr_r2_fastq
    position: 13
    shellQuote: true
- id: sr_readgroups
  doc: Readgroup information for the short-read fastq files
  type: string[]?
  inputBinding:
    prefix: --sr_readgroups
    position: 14
    shellQuote: true
- id: sr_aln
  doc: Short-read BAM or CRAM files
  type: File[]?
  secondaryFiles:
  - pattern: ^.bai
    required: false
  - pattern: ^.crai
    required: false
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    prefix: --sr_aln
    position: 15
    shellQuote: true
  sbg:fileTypes: BAM, CRAM
- id: lr_aln
  doc: Long-read BAM or CRAM files
  type: File[]?
  secondaryFiles:
  - pattern: ^.bai
    required: false
  - pattern: ^.crai
    required: false
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    prefix: --lr_aln
    position: 16
    shellQuote: true
  sbg:fileTypes: BAM, CRAM
- id: lr_align_input
  doc: Align the input long-read BAM/CRAM/uBAM file to the reference genome
  type: boolean?
  default: false
  inputBinding:
    prefix: --lr_align_input
    position: 17
    shellQuote: true
- id: lr_input_ref
  doc: |-
    Used to decode the input long-read alignment file. Required if the input file is in the CRAM/uCRAM formats
  type: File?
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: false
  inputBinding:
    prefix: --lr_input_ref
    position: 18
    shellQuote: true
  sbg:fileTypes: FA, FASTA
- id: model_bundle
  doc: The model bundle file
  type: File
  inputBinding:
    prefix: -m
    position: 11
    shellQuote: true
- id: dbSNP
  doc: |-
    dbSNP vcf file Supplying this file will annotate variants with their dbSNP refSNP ID numbers.
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: -d
    position: 100
    shellQuote: true
- id: diploid_bed
  doc: |-
    interval in the reference to restrict diploid variant calling, in BED file format. Supplying this file will limit diploid variant calling to the intervals inside the BED file.
  type: File?
  inputBinding:
    prefix: -b
    position: 110
    shellQuote: true
  sbg:fileTypes: BED
- id: sr_duplicate_marking
  doc: "Options for duplicate marking. (default: 'markdup')"
  type:
  - 'null'
  - name: sr_duplicate_marking
    type: enum
    symbols:
    - markdup
    - rmdup
    - none
  inputBinding:
    prefix: --sr_duplicate_marking
    position: 1000
    shellQuote: true
- id: bam_format
  doc: 'Use the BAM format instead of CRAM for output aligned files (default: False)'
  type: boolean?
  default: false
  inputBinding:
    prefix: --bam_format
    position: 1200
    shellQuote: true
- id: gvcf
  doc: |-
    Generate a gVCF output file along with the VCF. (default generates only the VCF)
  type: boolean?
  default: false
  inputBinding:
    prefix: --gvcf
    position: 1200
    shellQuote: true
- id: cores
  doc: Number of threads/processes to use
  type: int?
  inputBinding:
    prefix: -t
    position: 1300
    shellQuote: true
- id: skip_svs
  doc: 'Skip SV calling (default: False)'
  type: boolean?
  default: false
  inputBinding:
    prefix: --skip_svs
    position: 1500
    shellQuote: true
- id: skip_cnv
  doc: 'Skip CNV calling (default: False)'
  type: boolean?
  default: false
  inputBinding:
    prefix: --skip_cnv
    position: 1510
    shellQuote: true
- id: skip_mosdepth
  doc: 'Skip QC with mosdepth (default: False)'
  type: boolean?
  default: false
  inputBinding:
    prefix: --skip_mosdepth
    position: 1600
    shellQuote: true
- id: skip_multiqc
  doc: 'Skip multiQC report generation (default: False)'
  type: boolean?
  default: false
  inputBinding:
    prefix: --skip_multiqc
    position: 1650
    shellQuote: true
- id: rgsm
  doc: Overwrite the SM tag of the input readgroups for compatibility
  type: string?
  inputBinding:
    prefix: --rgsm
    position: 1700
    shellQuote: true
- id: output_vcf
  doc: Output VCF File. The file name must end in .vcf.gz
  type: string
  inputBinding:
    position: 10000
    shellQuote: true
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB].
  type: int?

outputs:
- id: small_variants
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputBinding:
    glob: $(inputs.output_vcf)
  sbg:fileTypes: VCF.GZ
- id: structural_variants
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputBinding:
    glob: $(inputs.output_vcf.replace(".vcf.gz", ".sv.vcf.gz"))
  sbg:fileTypes: VCF.GZ
- id: copy_number_variants
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputBinding:
    glob: $(inputs.output_vcf.replace(".vcf.gz", ".cnv.vcf.gz"))
  sbg:fileTypes: VCF.GZ
- id: out_alignments
  type: File[]?
  secondaryFiles:
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  outputBinding:
    glob:
    - '*.cram'
    - '*.bam'
- id: mosdepth_out
  type: File[]?
  outputBinding:
    glob: '*_mosdepth_*'
- id: qc_out
  type: Directory?
  outputBinding:
    glob: '*_metrics'
    loadListing: deep_listing

baseCommand:
- sentieon-cli
- dnascope-hybrid
arguments:
- prefix: --bwt_max_mem
  position: 3000
  valueFrom: 24G
  shellQuote: false
