cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_LongReadSV
doc: |-
  Sentieon SV calling for PacBio HiFi and Oxford Nanopore long reads.
  
  ### Inputs:
  #### Required
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  - ``Platform``: PacBio HiFi or Oxford Nanopore

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
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.06
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
    required: true
  inputBinding:
    prefix: -r
    position: 0
    shellQuote: false
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
    shellQuote: false
  sbg:fileTypes: BAM, CRAM
- id: platform
  label: Sequencing platform
  doc: |-
    PacBio HiFi or Oxford Nanopore (ONT)
  type:
  - 'null'
  - name: platform
    type: enum
    symbols:
    - PacBioHiFi
    - ONT
  default: PacBioHiFi
  inputBinding:
    prefix: --model
    position: 11
    shellQuote: true
    valueFrom: |-
      ${
          if (self === "PacBioHiFi") {
              return "/opt/dnascope_models/SentieonLongReadSVHiFiBeta0.1.model";
          }
          else if (self === "ONT") {
              return "/opt/dnascope_models/SentieonLongReadSVONTBeta0.1.model";
          }
          return ""
       }
  sbg:toolDefaultValue: PacBioHiFi
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
  shellQuote: false
