cwlVersion: v1.2
class: CommandLineTool
label: Sentieon_CNVscope
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
    secondaryFiles:
    - pattern: .fai
      required: true
    - pattern: ^.dict
      required: false
  input_bam:
    type: File[]
    doc: "sample BAM or CRAM file"
    secondaryFiles:
    - pattern: ^.bai
      required: false
    - pattern: ^.crai
      required: false
    - pattern: .bai
      required: false
    - pattern: .crai
      required: false
  model_bundle:
    type: File
    doc: "The model bundle file"
  output_vcf:
    type: string
    doc: "Output VCF File. The file name must end in .vcf.gz"
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

arguments:
- position: 0
  valueFrom: |-
    ${
        var files = [].concat(inputs.input_bam);
        files.sort()

        var filenames = []
        for (var i = 0; i < files.length; i++) {
            filenames.push(files[i].path)
        }
        var cmd_driver = "sentieon driver -r ".concat(inputs.reference.path)
        var cmd1 = cmd_driver.concat(" -i ").concat(filenames.join(" -i "))
        var tmp_vcf = inputs.output_vcf.concat(".tmp.vcf.gz")
        cmd1 = cmd1.concat(" --algo CNVscope --model ").concat(inputs.model_bundle.path).concat("/cnv.model ").concat(tmp_vcf)
        
        var cmd2 = cmd_driver.concat(" --algo CNVModelApply --model ").concat(inputs.model_bundle.path).concat("/cnv.model ").concat("-v ").concat(tmp_vcf).concat(" ").concat(inputs.output_vcf)
        return cmd1.concat(" && ").concat(cmd2).concat(" && rm ").concat(tmp_vcf).concat(" ").concat(tmp_vcf).concat(".tbi")
    }

