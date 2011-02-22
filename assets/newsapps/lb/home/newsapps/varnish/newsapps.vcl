backend app1 {
    .host = "10.214.18.128";
    .port = "80";
}

backend app2 {
    .host = "10.192.225.178";
    .port = "80";
}

acl purge {
    "127.0.0.1";
    "10.214.18.128";  # app1
    "50.16.75.56";
    "10.192.225.178"; # app2
    "50.16.32.37";
    "10.211.27.5"; # db
    "75.101.209.41";
    "10.207.13.148"; # cron
    "174.129.118.61";
}

director TwoPlayer random {
    {
        .backend = app1;
        .weight = 1;
    }  
    {
        .backend = app2;
        .weight = 1;
    }
}

sub vcl_recv {
    set req.backend = TwoPlayer;

    # Filter PURGE requests
	if (req.request == "PURGE") {
		if(!client.ip ~ purge) {
			error 405 "Not allowed.";
	    }

        # Purge URLs matching a regex
		purge("req.url ~ " req.url " && req.http.host == " req.http.host);
		error 200 "Purged";
	}

    # Append X-Forwarded-For header
    if (req.http.x-forwarded-for) { 
 	    set req.http.X-Forwarded-For = req.http.X-Forwarded-For ", " client.ip; 
 	} else { 
 	    set req.http.X-Forwarded-For = client.ip; 
 	}  
    
    # Don't cache POSTSs
    if(req.request == "POST") { 
        return(pass);
    }
    
    # Only cache elections
    if (!(req.http.host ~ "^(www.)?elections\.chicagotribune\.com" ||
        req.http.host ~ "^(www.)?elections\.apps\.chicagotribune\.com" ||
        req.http.host ~ "^elections-new\.tribapps\.com")) {
        return(pass);
    }
    
    # Allow uncached access to the admin
	if (req.url ~ "^/admin") {
		return(pass);
	}
	
	# Normalize Accept-Encoding to reduce vary
    if (req.http.Accept-Encoding) {
        if (req.http.User-Agent ~ "MSIE 6") {
            unset req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            unset req.http.Accept-Encoding;
        }
    }
	
	# Strip cookies
	unset req.http.cookie;
	
	# Don't respect pragma: no-cache or Cache-Control: no-cache
	unset req.http.Pragma;
	unset req.http.Cache-Control;

    # Enable a one-minute grace period: http://www.varnish-cache.org/wiki/VCL#Grace
    set req.grace = 1m;
}
	
sub vcl_fetch {
    # Don't cache POSTSs
    if(req.request == "POST") { 
        return(pass);
    }

    # Only cache elections
    if (!(req.http.host ~ "^(www.)?elections\.chicagotribune\.com" ||
        req.http.host ~ "^(www.)?elections\.apps\.chicagotribune\.com" ||
        req.http.host ~ "^elections-new\.tribapps\.com")) {
        return(pass);
    }

    # Allow uncached access to the admin
    if (req.url ~ "^/admin") {
    	return(pass);
    }
    
    # Don't cache things which specifically say not to
	if (beresp.http.Cache-Control ~ "no-cache") {
	    return(pass);
	}

    # Process Edge-side includes
    esi;
    
    # Strip cookies
    unset beresp.http.Set-Cookie;
	
	# Enable a one-minute grace period: http://www.varnish-cache.org/wiki/VCL#Grace
    set req.grace = 1m;
}
