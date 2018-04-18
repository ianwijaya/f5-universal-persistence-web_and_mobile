when HTTP_REQUEST {
    #log local0. "OK"
    set uri [HTTP::uri]
    if {$uri starts_with "/"} {
        if { [HTTP::method] eq "POST" } {
          ## Trigger the collection for up to 1MB of data
          if { [HTTP::header Content-Length] ne "" and [HTTP::header value Content-Length] <= 1048576 } {
             set content_length [HTTP::header value Content-Length]
          } else {
             set content_length 1048576
          }
          ## Check if $content-length is not set to 0
          if { $content_length > 0 } {
             HTTP::collect $content_length
          }
       }
    } else {
    	if { [HTTP::cookie exists "JSESSIONID"] } {
	        persist uie [HTTP::cookie "JSESSIONID"] 1800
    	} else {
    		set jsess [findstr [HTTP::uri] "JSESSIONID" 11 ";"]
    		if { $jsess != "" } {
    			persist uie $jsess 1800
    			#log local0. "PersistJSESS $jsess"
    		}
    	}
    }
}

when HTTP_REQUEST_DATA {
   set content_id [findstr [HTTP::payload] ipassport 0 ","] 
   set ipassport [string map {"\"" "" "\'" "" " " ""}  [lindex [split $content_id ":"] 1]]
   persist uie $ipassport 1800
   #log local0. "ipassport = $ipassport"
}

when HTTP_RESPONSE {
   if {[HTTP::status] == 200 } {
      #mobile URI
      if {$uri starts_with "/"} {
        log local0. $uri
        HTTP::collect [HTTP::header Content-Length]
        #log local0. [HTTP::header Content-Length]
      } else {
      	if { [HTTP::cookie exists "JSESSIONID"] } {
		    persist add uie [HTTP::cookie "JSESSIONID"] 1800
	    }
      }
      
   }
}
when HTTP_RESPONSE_DATA {
    #log local0. [HTTP::payload]
    set content_id [findstr [HTTP::payload] ipassport 0 ","] 
    set ipassport [string map {"\"" "" "\'" "" " " ""}  [lindex [split $content_id ":"] 1]]
    log local0. $ipassport
    persist add uie $ipassport 1800
}
