$(document).ready(function () {
    var codeElements = $(".r");

    codeElements.filter("pre").before($('<button class="toggle_code">Show Code</button>'));
    codeElements.filter("pre").hide()

    var codeToggleButtons = $(".toggle_code");

    codeToggleButtons.css("font-size", "70%");

    codeToggleButtons.on("click", function () {
        $(this).next().slideToggle();

        if($(this).text()=="Hide Code"){
            $(this).text("Show code")
        }else {
            $(this).text("Hide Code")
        }
    });
});
