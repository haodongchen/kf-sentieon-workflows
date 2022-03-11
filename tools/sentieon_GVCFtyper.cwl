cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_GVCFtyper
doc: |-
  The Sentieon **GVCFtyper** binary performs joint genotyping using One or more GVCFs.
  
  ### Inputs:
  - ``Reference``: Location of the reference FASTA file (Required)
  - ``Inputs``: GVCFs (Required)

  ### Notes:
  * Set `--genotype_model=coalescent --emit_conf=10 --call_conf=10` to match GATK 3.7, 3.8, 4.0.
  * Set `--genotype_model=multinomial --emit_conf=30 --call_conf=30` to match GATK 4.1.

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
            return 3000 * Math.ceil(inputs.input_vcfs.length / 1000 + 1)
        }
    }
- class: DockerRequirement
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202112.01_hifi
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
  doc: Reference fasta file with associated indexes
  type: File
  inputBinding:
    prefix: -r
    position: 1
  secondaryFiles:
  - pattern: .fai
    required: true
  - pattern: ^.dict
    required: true
  sbg:fileTypes: FA, FASTA
- id: input_vcfs
  label: Input GVCFs
  type: 
  - type: array
    items: File
    inputBinding:
      separate: true
  secondaryFiles:
    - pattern: .tbi
      required: false
    - pattern: .idx
      required: false
  inputBinding:
    position: 110
  sbg:fileTypes: VCF, VCF.GZ, GVCF, GVCF.GZ
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
    position: 11
- id: emit_mode
  label: Emit mode
  doc: |-
    Emit mode: variant, confident or all (default: variant)
  type:
  - 'null'
  - name: emit_mode
    type: enum
    symbols:
    - variant
    - confident
    - all
  inputBinding:
    prefix: --emit_mode
    position: 11
  sbg:toolDefaultValue: 'variant'
- id: call_conf
  label: Call confidence level
  doc: |-
    Call confidence level (default: 30)
  type: int?
  inputBinding:
    prefix: --call_conf
    position: 11
  sbg:toolDefaultValue: '30'
- id: emit_conf
  label: Emit confidence level
  doc: |-
    Emit confidence level (default: 30)
  type: int?
  inputBinding:
    prefix: --emit_conf
    position: 11
  sbg:toolDefaultValue: '30'
- id: genotype_model
  label: Genotype model
  doc: |-
    Genotype model: coalescent or multinomial. 
    While the coalescent mode is theoretically more accuracy for smaller cohorts, the multinomial mode is equally accurate with large cohorts and scales better with a very large numbers of samples.
  type:
  - 'null'
  - name: genotype_model
    type: enum
    symbols:
    - coalescent
    - multinomial
  inputBinding:
    prefix: --genotype_model
    position: 11
  default: multinomial
  sbg:toolDefaultValue: 'multinomial'
- id: max_alt_alleles
  label: Maximum alt alleles
  doc: |-
    Maximum number of alternate alleles (default: 100)
  type: int?
  inputBinding:
    prefix: --max_alt_alleles
    position: 11
  sbg:toolDefaultValue: '100'
- id: output_file_name
  label: Output file name
  doc: The output VCF file name. Must end with ".vcf.gz".
  type: string?
- id: cpu_per_job
  label: CPU per job
  doc: CPU per job
  type: int?
- id: mem_per_job
  label: Memory per job
  doc: Memory per job[MB]
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
- prefix: ''
  position: 10
  valueFrom: "--algo GVCFtyper"
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        if (inputs.output_file_name)
            return inputs.output_file_name
        else
            return "output.vcf.gz"
    }
  shellQuote: false
