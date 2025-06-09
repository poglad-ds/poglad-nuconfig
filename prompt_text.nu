## 
## MOTD
## Just current day
##
print ((date now | format date $"(ansi yellow)%A (ansi white)| (ansi yellow)%d/%m/%Y" ) | str capitalize)

##
## Respects git, but recure gstat module for work
## Configured for Windows, but respects Linux subsustem mounting naming with /mnt/$mount 
## 
## Can be stripped here ↓
let mnt = $"(ansi white)/(ansi red)mnt(ansi white)"

$env.PROMPT_COMMAND = { $"(ansi white)[== (prompt_path)(prompt_check_git)(ansi white) ==](ansi reset)" }
$env.PROMPT_COMMAND_RIGHT = { () }

def prompt_path [] {
    let pwd  = pwd | str replace -a "\\" "/"
    let split = $pwd | split row ":/"

    let mount = $split | first
    let user = ($env.USERPROFILE | str replace -a "\\" "/")
    if ( $pwd |  str contains $user ) {
        let $path = $pwd | str replace -a -r $"($user)[/]?" ""
        return $"(ansi white)~(ansi red)home(ansi white)/(ansi cyan)($path | str downcase)(ansi reset)"
        
    }

    let path = $split | last | split row "/" | str join $"(ansi white)/(ansi cyan)"
    return $"($mnt)(ansi white)/(ansi red)($mount | str downcase)(ansi white)/(ansi cyan)($path | str downcase)(ansi reset)"
}


def prompt_check_git [] {
    let $repo = gstat
    if ( ($repo | get repo_name ) == "no_repository" ) {
        return ""    
    }
    mut remote_stat = ""
    if ($repo.remote != "") {
        $remote_stat = $" (ansi white)($repo.behind)(ansi green) (ansi white)($repo.ahead)(ansi yellow)"
    }
    
    mut unstaged_modified = ""
    if ($repo.wt_modified + $repo.wt_untracked > 0) {
        $unstaged_modified = $" (ansi white)($repo.wt_modified + $repo.wt_untracked)(ansi yellow)󱧮"
    }

    mut staged_modified = ""
    if ($repo.idx_added_staged + $repo.idx_modified_staged > 0) {
        $staged_modified = $" (ansi white)($repo.idx_added_staged + $repo.idx_modified_staged)(ansi green)󱚂"
    }
    

    $" |  (ansi grey)($repo.branch)($remote_stat)($unstaged_modified)($staged_modified)(ansi reset)"
}
