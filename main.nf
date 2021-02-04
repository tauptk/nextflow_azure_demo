params.run_csv = "resources/run_2.csv"
params.publish_dir = "output"

Channel
    .fromPath( params.run_csv )
    .splitCsv(header:true)
    .map( row -> tuple(file(row.content), file(row.style), row.iterations))
    .set{ neural_stylization_run_ch }

process neural_stylization {
    publishDir params.publish_dir, mode: 'copy', overwrite: true

    container 'nextflowazuredemoregistry.azurecr.io/neural-style:0.0.1'

    input:
    set file(content), file(style), iterations from neural_stylization_run_ch

    output:
    file output_file_name into neural_stylization_output_ch
 
    script:
    script = "/app/neural_style.py"
    model = "/app/imagenet-vgg-verydeep-19.mat"
    output_file_name = "${content.baseName}_${style.baseName}.jpeg"

    """
    python ${script} \
        --network ${model} \
        --content ${content} \
        --styles ${style} \
        --output ${output_file_name} \
        --iterations ${iterations}
    """
}
