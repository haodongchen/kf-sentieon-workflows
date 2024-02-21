cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_DNAscopeSV
doc: |-
  Run Sentieon germline SV (DNAscope) tool.
  
  ### Inputs:
  #### Required for all tools
  - ``Reference``: Location of the reference FASTA file.
  - ``Input BAM``: Location of the BAM/CRAM input file.
  ##### Optional for all tools
  - ``Interval``: interval in the reference that will be used in all tools. This argument can be specified as:
    -  ``BED_FILE``: location of the BED file containing the intervals. 
    -  ``PICARD_INTERVAL_FILE``: location of the file containing the intervals, following the Picard interval standard.
    -  ``VCF_FILE``: location of VCF containing variant records whose genomic coordinates will be used as intervals.
  - ``Quality recalibration table``: location of the quality recalibration table output from the BQSR stage.
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
- id: interval
  label: Interval
  doc: |-
    An option for interval in the reference that will be used in the software.
  type: File?
  inputBinding:
    prefix: --interval
    position: 5
    shellQuote: false
  sbg:fileTypes: BED, VCF, interval_list
- id: recal_table
  label: Quality recalibration table
  doc: |-
    Location of the quality recalibration table output from the BQSR stage. 
    Do not use this option if the input BAM has already been recalibrated.
  type: File?
  inputBinding:
    prefix: -q
    position: 2
    shellQuote: false
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
    position: 12
    shellQuote: false
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
  shellQuote: false
- prefix: '--var_type'
  position: 11
  valueFrom: bnd
  shellQuote: false
- prefix: ''
  position: 15
  valueFrom: tmp.variant.vcf.gz
  shellQuote: false
- prefix: ''
  position: 50
  valueFrom: |-
    ${
        return "&& sentieon driver -r " + inputs.reference.path + " --algo SVSolver -v tmp.variant.vcf.gz "
    }
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        if (inputs.output_file_name)
            return inputs.output_file_name
        else
            return "structural.variant.vcf.gz"
    }
  shellQuote: false
- prefix: ''
  position: 150
  valueFrom: '&& rm tmp.variant.vcf.gz*'
  shellQuote: false
