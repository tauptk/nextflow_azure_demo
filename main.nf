params.hello_world = "Hello World!"

process helloWorld {
    input:
    val print_value from params.hello_world

    output:
    stdout into helloWorldResult
 
    """
    echo ${print_value}
    """
}

process helloWorld2 {
    input:
    val print_value from helloWorldResult
 
    """
    echo ${print_value}
    """
}
 
 