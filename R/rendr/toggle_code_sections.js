$(document).ready(function () {
    var codeElements = $(".r");

    codeElements.filter("pre").before($('<button class="toggle_code">Show Code</button>'));
    codeElements.filter("pre").hide()

    $(".toggle_code").on("click", function () {
        $(this).next().slideToggle()

        if($(this).text()=="Hide Code"){
            $(this).text("Show code")
        }else {
            $(this).text("Hide Code")
        }
    });
});
