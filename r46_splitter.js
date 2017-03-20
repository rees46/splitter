window.r46segments = {}
window.r46_splitter = function(shop_key, experiment, total_segments, success) {

    // Validations
    if(!/^[a-z0-9A-Z]+$/.test(shop_key)) throw "Incorrect shop key";
    if( total_segments != parseInt(total_segments) || (total_segments < 2 || total_segments > 24) ) throw "Incorrect segments count: must be integer from 2 to 24";
    if(!/^[a-z0-9A-Z_]+$/.test(experiment)) throw "Incorrect experiment name: use only letters and numbers without spaces";

    // Process
    var segment = null;
    var XHR = window.XDomainRequest || window.XMLHttpRequest; 
    var xhr = new XHR();
    xhr.withCredentials = true;
    var url = window.location.protocol + '//split.rees46.com/?shop_key=' + shop_key + '&experiment=' + experiment + '&total_segments=' + total_segments + '&c=' + Math.random();

    // Sync or async?
    if(success && typeof(success) == 'function') {
        xhr.onreadystatechange = function(){
            if(xhr.readyState == 4) {
                if(xhr.status == 200) {
                    success(xhr.responseText);
                } else {
                    success(null);
                }
            }
        };
        xhr.open('GET', url, true);
        xhr.send();
    } else {
        xhr.open('GET', url, false);
        xhr.send();
        if (xhr.status === 200) {
            window.r46segments[experiment] = xhr.responseText;
            segment = xhr.responseText;
        } else {
            segment = null;
        }
        return segment;
    }
    
};

