Channel
    .fromPath( params.run_csv )
    .splitCsv(header:true)
    .map( row -> tuple(file(row.content), file(row.style), row.iterations))
    .set{ neural_stylization_run_ch }

process neural_stylization {
    input:
    set file(content), file(style), iterations from neural_stylization_run_ch

    output:
    set file(content_unique_name), file(style_unique_name), file(output) into neural_stylization_output_ch
 
    script:
    script = "/app/neural_style.py"
    model = "/app/imagenet-vgg-verydeep-19.mat"
    content_unique_name = "${content.baseName}_${style.baseName}_${iterations}_input.jpeg"
    style_unique_name = "${content.baseName}_${style.baseName}_${iterations}_style.jpeg"
    output = "${content.baseName}_${style.baseName}_${iterations}_output.jpeg"

    """
    cp ${content} ${content_unique_name}
    cp ${style} ${style_unique_name}
    python ${script} \
        --network ${model} \
        --content ${content_unique_name} \
        --styles ${style_unique_name} \
        --output ${output} \
        --iterations ${iterations}
    """
}

neural_stylization_output_ch
    .collect()
    .flatten()
    .set{ composition_input_ch }

process create_composition {
    publishDir params.publish_dir, mode: 'copy', overwrite: true
    
    input:
    file(input_file) from composition_input_ch.collect()

    output:
    file(composition_output) into composition_output_ch
 
    script:
    script = "/app/composition_app.dll"
    row_length = 3
    composition_output = "composition_${workflow.sessionId}.bmp"
    input_files = input_file.join(",")

    """
    dotnet ${script} \
        --output ${composition_output} \
        -i ${input_files} \
        -c ${row_length}
    """
}
