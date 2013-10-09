# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
# 
# Default backend definition.  Set this to point to your content
# server.
# 
backend default {
	.host = "127.0.0.1";
	.port = "888";
	.connect_timeout = 100s;
	.first_byte_timeout = 500s;
	.between_bytes_timeout = 200s;
	.max_connections = 800;
}

acl purge {
	"localhost";
	"127.0.0.1";
}

# 
# Below is a commented-out copy of the default VCL logic.  If you
# redefine any of these subroutines, the built-in logic will be
# appended to your code.

sub vcl_recv {
 
#	if (req.http.host ~ "(www.zhukun.net)") { 
#		set req.backend = default; 
#	} else { 
#		return (pass); 
#	} 
 
	set req.grace = 2m;
 
	# Set X-Forwarded-For header for logging in nginx
	remove req.http.X-Forwarded-For;
	set req.http.X-Forwarded-For = client.ip;

	# Remove has_js and CloudFlare/Google Analytics __* cookies.
	set req.http.Cookie = regsuball(req.http.Cookie, "(^|;\s*)(_[_a-z]+|has_js)=[^;]*", "");
	# Remove a ";" prefix, if present.
	set req.http.Cookie = regsub(req.http.Cookie, "^;\s*", "");
	 
	if (req.request == "PURGE") {
		# If not allowed then a error 405 is returned
		if (!client.ip ~ purge) {
			error 405 "This IP is not allowed to send PURGE requests.";
		}	
		# If allowed, do a cache_lookup -> vlc_hit() or vlc_miss()
		return (lookup);
	}
 
	if (req.request != "GET" && req.request != "HEAD") {
        	return (pass);
	}
	if (req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
		unset req.http.cookie;
	}
	if (req.http.cookie ~ "^ *$") {
		unset req.http.cookie;
	}
	if (!req.http.cookie) {
		unset req.http.cookie;
	}
	if (req.http.Authorization || req.http.Cookie) {
		return (pass);
	}
	# Normalize Accept-Encoding header and compression
	if (req.http.Accept-Encoding) {
		# Do no compress compressed files...
		if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
				remove req.http.Accept-Encoding;
		} elsif (req.http.Accept-Encoding ~ "gzip") {
				set req.http.Accept-Encoding = "gzip";
		} elsif (req.http.Accept-Encoding ~ "deflate") {
				set req.http.Accept-Encoding = "deflate";
		} else {
			remove req.http.Accept-Encoding;
		}
	}
	
	# ----- Start Wordpress specific configuration -----
	set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-1=[^;]+(; )?", "");
	set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-time-1=[^;]+(; )?", "");
	set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=[^;]+(; )?", "");
 
	if (req.url ~ "/feed") {
		return (pass);
	}
	if (req.url ~ "/wp-(login|admin|cron)" || req.url ~ "preview=true") {
		return (pass);
	}
	if (req.url ~ "wp-content/themes/" && req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
		unset req.http.cookie;
	}
	if (req.url ~ "/wp-content/uploads/") {
		return (pass);
	}
	if (req.http.Cookie ~ "wordpress_" || req.http.Cookie ~ "comment_") {
		return (pass);
	}
	# ----- End Wordpress specific configuration -----
 
	# ----- Start lnmp specific configuration -----
	if (req.url ~ "/phpmyadmin") {
		return (pass);
	}
	# ----- Start lnmp specific configuration -----

	return (lookup);
}

sub vcl_fetch {
	if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {
		set beresp.ttl = 300s;
		return (hit_for_pass);
	}
	return (deliver);
}
 
sub vcl_hit {
	if (req.request == "PURGE") {
		purge;
		error 200 "Purged.";
	}
	return(deliver);
}
 
sub vcl_miss {
	if (req.request == "PURGE") {
		purge;
		error 200 "Purged.";
	}
	return (fetch);
}
