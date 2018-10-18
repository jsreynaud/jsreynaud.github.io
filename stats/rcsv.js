$(function(){

    var renderers = $.extend(
        $.pivotUtilities.renderers,
        $.pivotUtilities.c3_renderers,
        $.pivotUtilities.d3_renderers,
        $.pivotUtilities.export_renderers
    );

    var data_to_use = null;
    var config_to_use = {
                    rows: ["Package name"],
                    cols: ["Date"],
                            aggregatorName: ["Sum"],
                            vals: ["Download count"],
                            hiddenAttributes: [""],
        renderers: renderers };

    function Update() {
        $("#output").empty().text("Loading...");
        var val = $("#csv").val();
        Papa.parse(val, {
            download: true,
            header: true,
            skipEmptyLines: true,
            complete: function(parsed){
                data_to_use = parsed.data;
                console.log("Finished:", data_to_use);
                $("#output").pivotUI(data_to_use, config_to_use , true);
            }
        });
    }


    Papa.parse("datasets.csv", {
        download: true,
        header: true,
        skipEmptyLines: true,
        complete: function(parsed) {
            var csvlist_arr = parsed.data;
            var pkg = $("<optgroup>", {label: ""});
            for(var i in csvlist_arr)
            {
                var dataset = csvlist_arr[i];
                if(dataset.Package != pkg.attr("label"))
                {
                    pkg = $("<optgroup>", {label: dataset.Package}).appendTo($("#csv"));
                }
                pkg.append($("<option>", {value: dataset.csv}).text(dataset.Item +": " +dataset.Title));
            }
            $("#csv").chosen();
            $("#csv").bind("change", function(event){
                console.log(event);
                Update();
            });
        }
    });

    Papa.parse("config.csv", {
        download: true,
        header: true,
        skipEmptyLines: true,
        complete: function(parsed) {
            var csvlist_arr = parsed.data;
            var pkg = $("<optgroup>", {label: ""});
            for(var i in csvlist_arr)
            {
                var dataset = csvlist_arr[i];
                if(dataset.Package != pkg.attr("label"))
                {
                    pkg = $("<optgroup>", {label: dataset.Package}).appendTo($("#template"));
                }
                pkg.append($("<option>", {value: dataset.csv}).text(dataset.Title));
            }
            $("#template").chosen();
            $("#template").bind("change", function(event){
                console.log(event);
                $.getJSON( $("#template").val(), function(data) {
                    config_to_use = data;
                    console.log(config_to_use);
                    Update();
                });
            });
        }
    });



    $("#save").on("click", function(){
        var config = $("#output").data("pivotUIOptions");
        console.log($("#output"));
        var config_copy = JSON.parse(JSON.stringify(config));
        delete config_copy["aggregators"];
        delete config_copy["renderers"];
        console.log(config_copy);
    });

});
