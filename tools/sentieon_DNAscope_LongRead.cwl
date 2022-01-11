cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_DNAscope_LongRead
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
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112_hifi

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
    position: 10
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
    position: 11
    shellQuote: false
  sbg:fileTypes: BAM, CRAM
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".gz".
  type: string?
- id: dbSNP
  label: dbSNP VCF file
  doc: |-
    Supplying this file will annotate variants with their dbSNP refSNP ID numbers. (optional)
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: -d
    position: 30
    shellQuote: false
- id: bed
  label: Region BED file
  doc: |-
    Supplying this file will limit variant calling to the intervals inside the BED file. (optional)
  type: File?
  inputBinding:
    prefix: -b
    position: 39
    shellQuote: false
  sbg:fileTypes: BED
- id: mhc
  label: MHC BED file
  doc: |-
    Supplying this file will enable the special handling of the MHC region. (optional)
  type: File?
  inputBinding:
    prefix: -B
    position: 60
    shellQuote: false
  sbg:fileTypes: BED
- id: output_phased_regions
  label: Output phased regions
  doc: |-
    Output the BED file of phased regions (off by default)
  type: boolean?
  inputBinding:
    prefix: -p
    position: 70
    shellQuote: false
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
    outputEval: $(inheritMetadata(self, inputs.input))
  sbg:fileTypes: VCF.GZ

baseCommand:
- /bin/bash
- /opt/dnascope_hifi/DNAscopeHiFiBeta0.4.pipeline/dnascope_HiFi.sh
arguments:
- prefix: ''
  position: 1
  valueFrom: -m /opt/dnascope_hifi/DNAscopeHiFiBeta0.4.pipeline/DNAscopeHiFiBeta0.4.model
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        if (inputs.output_file_name)
            return inputs.output_file_name
        else
            var basename = inputs.input.nameroot.split("/").pop()
            return basename.concat(".vcf.gz")
    }
  shellQuote: false
