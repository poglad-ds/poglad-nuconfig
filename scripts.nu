##
## cd [mount] [path] 
## Just Windows overload with ability to skip useless prompt "C:/", boring! With autocompletion ot target $mount 
##
 
def --env mnt [mount: string] {
    
    let mnt = [$mount, ":/"] | str join
    cd $mnt
}

def cd_mnt_help_dsk [] {
    (sys disks | select mount | each {|a| $a.mount})
} 

def cd_mnt_help_path [context: string] {
    (ls $"($context | split words | last):/" | where type == dir | each {|a| $a.name})
}


def --env "cd -m" [mount: string@cd_mnt_help_dsk, location: path@cd_mnt_help_path] {
    cd $"($location)/"
}

##
## ask [model] [... prompt:string] 
## Generate a single-off ollama request, without story
##

def ollama_shortkeys [] {
    (ollama list | parse "{name} {B}" | skip 1 | each { |model| $model.name })
}

# Well, happens. That life 4u
def thinking_models [] {
    ["qwen3:latest", "qwen3:8b"]
}

def ask [model: string@ollama_shortkeys, ...prompt] {
    let time_start = (date now)
    mut afterword = ""
        
    if ((ollama_shortkeys | filter { |val| $val == $model } | length ) <= 0 ) {
        return (print $"Not supported model ($model)")
    }

    match $model {
         "qwen3" => {
            $afterword = "/no_think"
        }
    }

    let question = $prompt | append $afterword  | str join ' '

    mut $answer = ollama run $model $question

    if ( thinking_models | any { |val| $val == $model } ) {
        $answer = $answer | split row "...done thinking." | last
    }
    let time_end = (date now) - $time_start
    ($answer | glow) 
    print $"Processing takes ($time_end)"
}

##
## Git helpers
##

def "add" [] {
    (git add -A)
}

def "commit" [...msg: string] {
    (git commit -m ($msg | str join ' '))
}

def "log" [file?:path] {
    if ($file != null ) {
        (git log --oneline --graph $file)
        return
    }
    
    (git log --oneline --graph)  
}
