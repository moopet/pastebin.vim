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
pastebin_api = 'http://pastebin.com/api_public.php'
# Set this to your preferred username, or "auto" to take your shell username
#user = 'anonymous'
user = 'auto'
# I have no idea what the point is to subdomain but will look it up later
subdomain = 'mydomain'
#################### END USER CONFIG ####################

if user == 'auto':
    if sys.platform == 'win32':
        user = os.getenv('USERNAME')
    elif sys.platform == 'linux2':
        user = os.getenv('USER')

def PBSendPOST(start=None, end=None):
    if start is None and end is None:
        code = '\n'.join(vim.current.buffer)
    else:
        code = '\n'.join(vim.current.buffer[int(start) - 1:int(end)])

    data = {
        'paste_name': user,
        'paste_subdomain': subdomain,
        'paste_code': code,
    # this is a hack - most of vim's filetypes are the same as pastebin's :)
    # I should put together a proper mapping table, but this is fine for now.
        'paste_format': vim.eval('&ft'),
    }

    u = urllib.urlopen(pastebin_api, urllib.urlencode(data))
    print u.read()
EOF
