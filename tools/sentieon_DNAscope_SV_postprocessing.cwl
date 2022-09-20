cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_DNAscopeSV_postprocessing
doc: |-
  Convert breakends identified by DNAscope/SVsolver to truvari inupt. Note
  that this results in some loss of accuracy and information
  compared to the raw breakpoint (BND) representation.
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input VCF``: Location of the BND VCF file.

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.05_sv
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement

hints:
- class: sbg:AWSInstanceType
  value: c4.large;ebs-gp2;100

inputs:
- id: sentieon_license
  label: Sentieon license
  doc: License server host and port
  type: string
- id: input_vcf
  label: Input VCF
  doc: Input BND VCF file
  type: File
  secondaryFiles:
  - pattern: .tbi
    required: true
  inputBinding:
    position: 1
    shellQuote: false
  sbg:fileTypes: VCF.GZ
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
    position: 2
    shellQuote: false
  sbg:fileTypes: FA, FASTA
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".vcf.gz".
  type: string?

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
- pyexec
- /opt/bnd_to_insdel.py
arguments:
- prefix: ''
  position: 3
  valueFrom: 'unsorted.vcf.gz'
  shellQuote: false
- prefix: ''
  position: 10
  valueFrom: |-
    ${
        return "&& bcftools sort -O z -o " + inputs.output_file_name + " unsorted.vcf.gz"
    }
  shellQuote: false
- prefix: ''
  position: 15
  valueFrom: |-
    ${
        return "&& bcftools index -t " + inputs.output_file_name + " && rm unsorted.vcf.gz*"
    }
  shellQuote: false
