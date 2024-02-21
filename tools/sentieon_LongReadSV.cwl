cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_LongReadSV
doc: |-
  Sentieon SV calling for PacBio HiFi and Oxford Nanopore long reads.
  
  ### Inputs:
  #### Required
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  - ``Model``: LongReadSV Model bundle

$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
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
            return 32000
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202308.02
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
  label: Reference
  doc: Reference fasta with associated fai index
  type: File
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: false
  inputBinding:
    prefix: -r
    position: 0
    shellQuote: true
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: File
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
    prefix: -i
    position: 1
    shellQuote: true
  sbg:fileTypes: BAM, CRAM
- id: model_bundle
  label: Model bundle
  type: File
  inputBinding:
    prefix: --model
    position: 11
    valueFrom: |-
      $(self.path)/longreadsv.model
- id: min_sv_size
  label: MIN_SV_SIZE
  doc:  minimum SV size in basepairs to output
  type: int?
  inputBinding:
    prefix: --min_sv_size
    shellQuote: true
    position: 12
  sbg:toolDefaultValue: 40
- id: min_map_qual
  label: MIN_MAP_QUAL
  doc:  minimum read mapping quality
  type: int?
  inputBinding:
    prefix: --min_map_qual
    shellQuote: true
    position: 12
  sbg:toolDefaultValue: 20
- id: min_dp
  label: MIN_DP
  doc:  Minimum depth
  type: int?
  inputBinding:
    prefix: --min_dp
    shellQuote: true
    position: 12
  sbg:toolDefaultValue: 2
- id: min_af
  label: MIN_AF
  doc:  Minimum af
  type: float?
  inputBinding:
    prefix: --min_af
    shellQuote: true
    position: 12
  sbg:toolDefaultValue: 0.15
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".vcf.gz".
  type: string
  inputBinding:
    position: 100
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
- id: output_vcf
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: true
  outputBinding:
    glob: '*.vcf.gz'
  sbg:fileTypes: VCF.GZ

baseCommand:
- sentieon
- driver
arguments:
- prefix: '--algo'
  position: 10
  valueFrom: LongReadSV
  shellQuote: true
