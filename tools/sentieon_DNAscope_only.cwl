cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_DNAscope
doc: |-
  Run Sentieon germline (DNAscope) tool.
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  ##### Optional for all tools
  - ``Interval``: interval in the reference that will be used in all tools. This argument can be specified as:
    -  ``BED_FILE``: location of the BED file containing the intervals. 
    -  ``PICARD_INTERVAL_FILE``: location of the file containing the intervals, following the Picard interval standard.
    -  ``VCF_FILE``: location of VCF containing variant records whose genomic coordinates will be used as intervals.
  - ``dbSNP``: dbSNP file.

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
  dockerPull: pgc-images.sbgenomics.com/hdchen/sentieon:202308.03
- class: EnvVarRequirement
  envDef:
  - envName: SENTIEON_LICENSE
    envValue: $(inputs.sentieon_license)
- class: InlineJavascriptRequirement
$namespaces:
  sbg: https://sevenbridges.com
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
    shellQuote: true
  sbg:fileTypes: FA, FASTA
- id: input_bam
  label: Input BAM
  doc: Input BAM file
  type: File
  secondaryFiles:
  - pattern: .bai
    required: false
  - pattern: .crai
    required: false
  inputBinding:
    prefix: -i
    position: 1
    shellQuote: true
  sbg:fileTypes: BAM, CRAM
- id: recal_table
  label: recal_table
  doc: BQSR table
  type: File?
  inputBinding:
    prefix: -q
    position: 2
    shellQuote: true
- id: interval
  label: Interval
  doc: |-
    An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
    shellQuote: true
  sbg:fileTypes: BED, VCF, interval_list
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
    position: 15
    shellQuote: true
- id: pcr_indel_model
  doc: |-
    PCR indel error model: none, hostile, aggressive, or conservative (default: conservative)
  type:
  - 'null'
  - name: pcr_indel_model
    type: enum
    symbols:
    - none
    - hostile
    - aggressive
    - conservative
  inputBinding:
    prefix: --pcr_indel_model
    position: 15
    shellQuote: true
  sbg:toolDefaultValue: conservative  
- id: emit_mode
  label: Emit mode
  doc: 'Emit mode: variant, confident, all or gvcf (default: variant)'
  type:
  - 'null'
  - name: emit_mode
    type: enum
    symbols:
    - variant
    - confident
    - all
    - gvcf
  inputBinding:
    prefix: --emit_mode
    position: 15
    shellQuote: true
  sbg:toolDefaultValue: variant
- id: var_type
  doc: |-
    Variant types to call: comma separated list of snp, indel or bnd (default: snp,indel)
  type: string?
  inputBinding:
    prefix: --var_type
    position: 15
- id: ploidy
  doc: |-
    Sample ploidy (default: 2)
  type: int?
  inputBinding:
    prefix: --ploidy
    position: 15
- id: call_conf
  label: Call confidence level
  doc: 'Call confidence level (default: 30)'
  type: int?
  inputBinding:
    prefix: --call_conf
    position: 15
    shellQuote: true
  sbg:toolDefaultValue: '30'
- id: emit_conf
  label: Emit confidence level
  doc: 'Emit confidence level (default: 30)'
  type: int?
  inputBinding:
    prefix: --emit_conf
    position: 15
    shellQuote: true
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
  default: multinomial
  inputBinding:
    prefix: --genotype_model
    position: 15
    shellQuote: true
  sbg:toolDefaultValue: multinomial
- id: given
  doc: |-
    Call only the variants given in a vcf file
  type: File?
  secondaryFiles:
  - pattern: .tbi
    required: false
  - pattern: .idx
    required: false
  inputBinding:
    prefix: --given
    position: 15
    shellQuote: true
- id: output_file_name
  label: Output file name
  doc: The output VCF file name.
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
  valueFrom: DNAscope
  shellQuote: true
