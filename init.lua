-- _G : 글로벌 환경 변수를 지정한다.
-- 초기화를 한번 해놓으면 어떤 lua 파일에서도 접근 가능하다.


-- 변수 정보 사람이 쉽게 읽을 수 있도록 도와주는 inspect 플러그인을 사용한다.
-- 테이블에 어떤 데이터가 담겨있는지 확인할 용도로 쓸려고 추가했다.
-- https://github.com/kikito/inspect.lua
_G.inspect = require("vim.inspect")
_G.jdyun = {
  debug = true, -- 디버그 출력을 할지 여부

  debug_print = function(message)
    if jdyun.debug == true then print(message) end
  end,

  -- debug 글로벌 변수로 함수 정보를 얻을 수 있다.
  -- level 1이 현재 함수
  -- level 2가 부모 함수
  -- level 3이 부모의 부모 함수 인데 parent_function_info 함수에서 호출했으니 level을 +1 더해줘야함
  parent_function_info = function()
     local info = debug.getinfo(3, "Sl")
     if info then return string.format("[%s]:%d", info.short_src, info.currentline) end
     return "[nil]:0"
  end,

  -- 현재 실행중인 스크립트의 경로 획득 
  -- https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file
  script_directory_path = function()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
  end,

  script_file_path = function()
   return debug.getinfo(2, "S").short_src
  end,
}

jdyun.debug_print("스크립트 실행 경로 : " .. jdyun.script_file_path())
jdyun.debug_print("nvim 설치 경로 : " .. vim.fn.stdpath "data")

-- impatient 플러그인을 제일먼저 로딩한다.
-- nvim 로딩 속도를 빠르게 하기
local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then impatient.enable_profile() end

for _, source in ipairs {
  "core.utils",
  "core.options",
  "core.bootstrap",
  "core.plugins",
  "core.autocmds",
  "core.mappings",
  "configs.which-key-register",
} do
  jdyun.debug_print "=============================================="
  jdyun.debug_print(source .. " 로딩 시작")
  jdyun.debug_print "=============================================="
  local status_ok, fault = pcall(require, source)
  if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

astronvim.conditional_func(astronvim.user_plugin_opts("polish", nil, false))



