
#
# discord_asm/0.1
# created and maintained by aika(_pikapi)
#
# Warning: this is an very early alpha version and is not yet intended to function as an api

.code64
.section .data
  welcome:    .asciz "Welcome to discord-asm!\nPerforming test call to fetch test channel\n"
  rest:       .asciz "https://discordapp.com/api/v6/%s"
  _test:      .asciz "channels/442744713607643147"
  _test_gid:  .asciz "guild_id"
  _parson_test:.asciz "Guild Id from parson: %s\n"
  _got:       .asciz "GET: %s\n"
  _discord_h: .asciz "Authorization: Bot %s"
  _discord_ag:.asciz "DiscordBot (discord_asm/0.1)"
  _token_f:   .asciz "token.txt"
  _f_ro:      .asciz "r"

.section .bss
  .lcomm _curl, 8
  .lcomm _token_handle, 8
  .lcomm _token, 128
  .lcomm _d_h, 200
  .lcomm _http_headers, 8
  .lcomm _url, 128
  .lcomm _tmp_json_ptr, 8

.section .text

  .globl main
  end:
    pop %rbp
    xor %rdi, %rdi
    call exit
    ret
  main:
    push %rbp
    mov $welcome, %rdi
    xor %rax, %rax
    call printf
  _read_token:
    mov $_token_f, %rdi
    mov $_f_ro, %rsi
    xor %rax, %rax
    call fopen
    mov $_token_handle, %rcx
    mov %rax, (%rcx)
    mov $_token, %rdi
    mov $128, %rsi
    mov %rax, %rdx
    xor %rax, %rax
    call fgets
    mov $_token_handle, %rcx
    mov (%rcx), %rdi
    xor %rax, %rax
    call fclose
    jmp _init_curl
  _curl_setopt:
    mov $_curl, %rcx
    mov (%rcx), %rdi
    xor %rax, %rax
    call curl_easy_setopt
    ret
  _test_parson:
    # rdi - string pointer
    call json_parse_string
    mov %rax, %rdi
    xor %rax, %rax
    call json_value_get_object
    mov $_tmp_json_ptr, %rcx
    mov %rax, (%rcx)
    mov $_test_gid, %rsi
    mov %rax, %rdi
    xor %rax, %rax
    call json_object_get_string
    mov %rax, %rsi
    mov $_parson_test, %rdi
    xor %rax, %rax
    call printf
    ret
  _curl_write_callback:
    xor %rax, %rax
    call _test_parson
    ret
  _init_curl:
    xor %rdi, %rdi
    call curl_easy_init
    mov $_curl, %rcx
    mov %rax, (%rcx)
    call _discord_header_init

    mov $0x2727, %rsi      # CURLOPT_HTTPHEADER
    mov $_http_headers, %rax
    mov (%rax), %rdx
    call _curl_setopt

    mov $0xe5, %rsi        # CURLOPT_HEADEROPT
    mov $0, %rdx           # CURLHEADER_UNIFIED
    call _curl_setopt

    mov $0x2722, %rsi      # CURLOPT_USERAGENT
    mov $_discord_ag, %rdx
    call _curl_setopt

    mov $0x4e2b, %rsi      # CURLOPT_WRITEFUNCTION
    mov $_curl_write_callback, %rdx
    call _curl_setopt

    jmp _test_connection
  _discord_rest_call:
    mov %rdi, %rdx
    mov $_url, %rdi
    mov $rest, %rsi
    xor %rax, %rax
    call sprintf
    mov $0x2712, %rsi      # CURLOPT_URL
    mov $_url, %rdx
    xor %rax, %rax
    call _curl_setopt
    ret
  _discord_header_init:
    mov $_d_h, %rdi
    mov $_discord_h, %rsi
    mov $_token, %rdx
    xor %rax, %rax
    call sprintf
    mov $0, %rdi
    mov $_d_h, %rsi
    xor %rax, %rax
    call curl_slist_append
    mov $_http_headers, %rcx
    mov %rax, (%rcx)
    ret
  _test_connection:
    mov $_test, %rdi
    call _discord_rest_call
    mov $_curl, %rcx
    mov (%rcx), %rdi
    xor %rax, %rax
    call curl_easy_perform
  _cleanup_curl:
    mov $_curl, %rcx
    mov (%rcx), %rdi
    xor %rax, %rax
    call curl_easy_cleanup
    jmp end
