function trim(s) {sub(/^[ \t\n]*/,"",s); sub(/[ \t\n]*$/,"",s); return s} 

PASS==1 && /^##/      { k="<"FILENAME" "$2">"    ; next     }  
PASS==1               { SNIP[k] = SNIP[k] sep $0 ; sep="\n" } 
PASS==2               { print }\
PASS==2 && /```julia/ { k=$2" "$3
                        print(trim(SNIP[k]),"\n```")
                        USED[k]++
                        while(getline x >0) if (x ~ /^```/) break }
END { for(k in SNIP)
        if (USED[k] != 1) {
          print("?? used "(USED[k]+0)" time(s) "k)>"/dev/stderr" } }