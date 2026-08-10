function Homigrad_PrePareHTML(code)
    return HTMLDefaultStyle .. [[
        <style>
            p {
                text-align: left;
                font-size: 1em;
    
                color: rgb(254,254,254);
    
                line-height: 1.45em;
                white-space: pre-wrap;
            }
        </style>
        <body style="color: white; overflow-y: hidden ">
            <div style="width: 50%; height: 100%; margin: 0 auto; overflow-y: auto">
        ]] .. code .. [[
             </div>
        </body>
        <script>
            for (let element of document.getElementsByTagName("a")) {
                element.href = ""
            }
        </script>
    ]]
end