" ViM Pastebin extension
"
" Original version by Dennis, at
" http://djcraven5.blogspot.com/2006/10/vimpastebin-post-to-pastebin-from.html
"
" Updated in 2008 Olivier Lê Thanh Duong <olethanh@gmail.com>
" to use an XML-RPC interface compatible with http://paste.debian.net/rpc-interface.html
"
" Updated in 2009 for python compatibility by Balazs Dianiska
" <balazs@longlake.co.uk>
"
" Updated in 2010 for pastebin.com compatibility, removed gajim and xmlrpc
" support.
"
" Updated in 2011 to make filetypes work (hack) and full file post work
" and to add automatic user detection by Ben Sinclair
" <ben@moopet.net>
"
" Make sure the Vim was compiled with +python before loading the script...
if !has("python")
        finish
endif

" Map a keystroke for Visual Mode only (default:F2)
:vmap <f2> :PasteCode<cr>

" Send to pastebin
:command -range             PasteCode :py PBSendPOST(<line1>,<line2>)
" Pastebin the complete file
:command                    PasteFile :py PBSendPOST()

python << EOF
import vim
import urllib
import os
import sys

################### BEGIN USER CONFIG ###################
# Set this to your preferred pastebin
service = 'pastebin'
# Set this to your preferred username, or "auto" to take your shell username
user = 'auto'
private = False
email = None
# subdomain (optional) will affect the resulting URL only
subdomain = None
#################### END USER CONFIG ####################

service_config = {
    'pastebin': {
        'api': 'http://pastebin.com/api_public.php',
        'keys': {
            'user': 'paste_name',
            'code': 'paste_code',
            'format': 'paste_format',
            'subdomain': 'paste_subdomain',
            'email': 'paste_email',
            'private': 'paste_private',
        },
        'filetypes': {
            'bash': ('sh'),
            'c': ('c'),
            'cpp': ('cpp'),
            'css': ('css'),
            'java': ('java'),
            'javascript': ('javascript'),
            'make': ('make'),
            'perl': ('perl'),
            'php': ('php'),
            'python': ('python'),
            'robots': ('robots'),
            'sql': ('sql'),
            'vala': ('vala'),
            'vim': ('vim'),
            'xml': ('xml'),
        }
    }
}

def get_format_from_filetype(service='pastebin'):
    ft = vim.eval('&ft')
    for name in service_config[service]['filetypes']:
        if ft == service_config[service]['filetypes'][name]:
            return name
    for name in service_config[service]['filetypes']:
        if ft in service_config[service]['filetypes'][name]:
            return name
    return 'text'

def get_user():
    if user == 'auto':
        if sys.platform == 'linux2' or sys.platform == 'sunos5':
            return os.getenv('USER')
        if sys.platform == 'win32':
            return os.getenv('USERNAME')
        return 'anonymous'
    elif user is not None:
        return user
    return 'anonymous'

def PBSendPOST(start=None, end=None):
    if start is None and end is None:
        code = '\n'.join(vim.current.buffer)
    else:
        code = '\n'.join(vim.current.buffer[int(start) - 1:int(end)])

    data = {}
    config = service_config[service]
    data[config['keys']['code']] = code
    data[config['keys']['format']] = get_format_from_filetype(service)
    if config['keys'].has_key('user'):
        data[config['keys']['user']] = get_user()
    if subdomain is not None and config['keys'].has_key('subdomain'):
        data[config['keys']['subdomain']] = subdomain
    if email is not None and config['keys'].has_key('email'):
        data[config['keys']['email']] = email
    if private and config['keys'].has_key('private'):
        data[config['keys']['private']] = 1 if private else 0

    u = urllib.urlopen(config['api'], urllib.urlencode(data))
    print u.read()
EOF
