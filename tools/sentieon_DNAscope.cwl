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
    position: 12
    shellQuote: true
- id: model_bundle
  label: DNAscope ML Model
  doc: |-
    Supplying this file will run DNAscope with a machine learning model. (optional)
  type: File?
- id: is_pcr_free
  default: false
  type: boolean
  doc: Set to true if the library is PCR-free
- id: emit_mode
  label: Emit mode
  doc: |-
    variant, confident, all or gvcf (default: variant)
  type: string?
  inputBinding:
    prefix: --emit_mode
    position: 12
    shellQuote: true
  sbg:toolDefaultValue: variant
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
  shellQuote: true
- prefix: ''
  position: 15
  valueFrom:  |-
    ${
        if (inputs.model_bundle)
            return "--model " + inputs.model_bundle.path+  "/dnascope.model"
    }
  shellQuote: false
- prefix: '--pcr_indel_model'
  position: 15
  valueFrom:  |-
    ${
        if (inputs.is_pcr_free)
            return "none"
        else
            return "conservative"
    }
  shellQuote: true
- prefix: ''
  position: 50
  valueFrom: |-
    ${
        if (inputs.model_bundle)
            return "tmp.variant.vcf.gz && sentieon driver -r " + inputs.reference.path + " --algo DNAModelApply --model " + inputs.model_bundle.path +  "/dnascope.model -v tmp.variant.vcf.gz"
    }
  shellQuote: false
- prefix: ''
  position: 100
  valueFrom: |-
    ${
        if (inputs.output_file_name)
            return inputs.output_file_name
        else
            if (inputs.emit_mode === "gvcf" )
                return "variant.g.vcf.gz"
            else
                return "variant.vcf.gz"
    }
  shellQuote: false
- prefix: ''
  position: 150
  valueFrom: '&& rm -f tmp.variant.vcf.gz*'
  shellQuote: false
