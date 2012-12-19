#!/usr/bin/env bash

. scripts/compile_app.sh

function compile_apps() {
	cd apps               
        for each in `ls`      
	do                    
		cd $each      
		compile_app $each.pp
		mv $each.dll $each  
		cd ..               
	done                        
	cd ..
}

