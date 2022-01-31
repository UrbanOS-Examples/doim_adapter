~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"~QQRG(d^%8VG^2$jkb`]Zy%W$l<_O88M^jd(R[g%6Za!E_r7Anup:S!BPfb==/3Y"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"e~Z.=P_uK_A:EHrl60G}<fOa9OZz0ySt/N;G|;128_@X?`>Ln&Z?G0H{urG2/9R7"
  set vm_args: "rel/vm.args"

  set config_providers: [
    {Mix.Releases.Config.Providers.Elixir, ["${RELEASE_ROOT_DIR}/etc/runtime.exs"]}
  ]
  set overlays: [
    {:copy, "rel/runtime.exs", "etc/runtime.exs"}
  ]
end


release :doim_adapter do
  set version: current_version(:doim_adapter)
  set applications: [
    :runtime_tools
  ]
end

