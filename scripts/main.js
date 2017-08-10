d3.csv('keeper-selection/data/2016EndingRosters.csv', function (data){

console.log('data', data);
    for (var i = 0; i < data.length; i++) {
        var element = data[i];
        var text = `<tr ` + (element.Kept==="1" ? 'class="table-danger"' : '') + `>
                        <td>` + element.V2 + `</td>
                        <td>` + element.Round + `</td>
                    </tr>`;
        $('#' + element.Member +'_roster tbody').append(text);
    }
});