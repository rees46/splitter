window.r46segments = {}
window.r46_splitter = function(shop_key, experiment, total_segments) {

    // Validations
    if(!/^[a-z0-9A-Z]+$/.test(shop_key)) throw "Incorrect shop key";
    if( total_segments != parseInt(total_segments) || (total_segments < 2 || total_segments > 24) ) throw "Incorrect segments count: must be integer from 2 to 24";
    if(!/^[a-z0-9A-Z]+$/.test(experiment)) throw "Incorrect experiment name: use only letters and numbers without spaces";

    // Process
    var segment = null;
    var XHR = window.XDomainRequest || window.XMLHttpRequest; var xhr = new XHR();
    xhr.open('GET', window.location.protocol + '//split.rees46.com/?shop_key=' + shop_key + '&experiment=' + experiment + '&total_segments=' + total_segments + '&c=' + Math.random(), false);
    xhr.send();
    if (xhr.status === 200) {
        window.r46segments[experiment] = xhr.responseText;
        segment = xhr.responseText;
    }
    return segment;
};

