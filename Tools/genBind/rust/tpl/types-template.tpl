/*
    The code is automatically generated by the genBind tool.
    Author: ying32
    https://github.com/ying32
*/
##
#![allow(non_snake_case)]
#![allow(improper_ctypes)]
#![allow(non_camel_case_types)]
#![allow(dead_code)]
#![allow(non_upper_case_globals)]
##
##
use std::os::raw::c_char;

##

{{/* 基础类型定义 */}}

{{range $tidex, $el := .BaseTypes}}
{{if isEmpty $el.FieldArch}}
  {{if eq $el.Kind "struct"}}

##
#[repr(C)]
pub struct {{$el.Name}} {
    {{range $field := $el.Fields}}
    pub {{covKeyword $field.Name}}: {{if $field.IsArr}}[{{end}}{{covType $field.Type}}{{if $field.IsArr}};{{$field.ArrLength}}]{{end}},
    {{end}}
}
##
  {{else if eq $el.Kind "set"}}
##
// set of {{$el.SetOf}}
pub type {{$el.Name}} = TSet;
##
  {{else}}
pub type {{$el.Name}} = {{covType $el.Type}};
  {{end}}
{{end}}
{{end}}
##


{{/* 类型，包含结构和枚举 */}}
{{range $el := .Types}}
  {{if eq $el.Kind "struct"}}
##
#[repr(C)]
pub struct {{$el.Name}} {
    {{range $field := $el.Fields}}
    pub {{covKeyword $field.Name}}: {{if $field.IsArr}}[{{end}}{{covType $field.Type}}{{if $field.IsArr}};{{$field.ArrLength}}]{{end}},
    {{end}}
}
  {{else if eq $el.Kind "enum"}}
##
#[repr(C)]
pub enum {{$el.Name}} {
    {{range $enum := $el.Enums}}
    {{$enum.Name}}{{if not (isEmpty $enum.Value)}} = {{$enum.Value}}{{end}},{{if not (isEmpty $enum.Comment)}} // {{html $enum.Comment}}{{end}}
    {{end}}
}
  {{else if eq $el.Kind "set"}}
##
// set of {{$el.SetOf}}
pub type {{$el.Name}} = TSet;
  {{else}}
##
pub type {{$el.Name}} = {{covType $el.Type}};
  {{end}}
{{end}}


{{/* 基础类型定义，只找arch的 */}}

{{range $tidex, $el := .BaseTypes}}
{{if not (isEmpty $el.FieldArch)}}
  {{if eq $el.Kind "struct"}}
##
##
{{if eq $el.FieldArch "i386"}}
#[cfg(not(target_arch = "x86"))]
{{else}}
#[cfg(not(target_arch = "x86_64"))]
{{end}}
#[repr(C)]
{{if ne $el.Name "TDWordFiller"}}pub {{end}}struct {{$el.Name}} {
    {{range $field := $el.Fields}}
      {{if not (or (eq $field.Name "_UnusedMsg") (eq $field.Type "TDWordFiller"))}}pub {{end}}{{covKeyword $field.Name}}: {{if $field.IsArr}}[{{end}}{{covType $field.Type}}{{if $field.IsArr}};{{$field.ArrLength}}]{{end}},
    {{end}}
}
  {{end}}
{{end}}
{{end}}

##
#[cfg(target_os = "linux")]
pub type PGdkWindow = usize;
//#[cfg(target_os = "linux")]
//pub type TXId = usize;
#[cfg(target_os = "linux")]
pub type PGtkFixed = usize;
##
##
#[cfg(target_os = "macos")]
pub type MyNSWindow = usize;
##

{{$buff := newBuffer}}

{{/* 事件定义 */}}
##
{{range $el := .Events}}
    {{if isEmpty $el.ReDefine}}
        {{$buff.Writeln "##"}}

        {{/* 注释 */}}
        {{$buff.Write "// fn ("}}
        {{range $idx, $ps := $el.Params}}
            {{if gt $idx 0}}
                {{$buff.Write ", "}}
            {{end}}
            {{if $ps.IsVar}}
                {{$buff.Write "*mut "}}
            {{end}}
            {{$buff.Write $ps.Name ": "}}
            {{if isObject $ps.Type}}
                {{$buff.Write "usize"}}
            {{else}}
                {{covType $ps.Type|$buff.Write}}
            {{end}}
         {{end}}
        {{$buff.Writeln ")"}}

        {{/* 类型定义 */}}
        {{$buff.Write "pub type " $el.Name " = fn("}}
        {{range $idx, $ps := $el.Params}}
            {{if gt $idx 0}}
                {{$buff.Write ", "}}
            {{end}}
            {{if $ps.IsVar}}
                {{$buff.Write "*mut "}}
            {{end}}
            {{if isObject $ps.Type}}
                {{$buff.Write "usize"}}
            {{else}}
                {{covType $ps.Type|$buff.Write}}
            {{end}}
        {{end}}
        {{$buff.Writeln ");"}}


    {{else}}
        {{$buff.Writeln "##"}}
        {{$buff.Writeln "pub type " $el.Name " = " $el.ReDefine ";"}}
    {{end}}
{{end}}


{{/* 常量定义 */}}
##



{{range $el := .Consts}}
    {{if not (isEmpty $el.Name)}}

        {{$isCur := hasPrefix $el.Name "cr"}}

        {{$buff.Write "const " $el.Name}}

        {{if hasPrefix $el.Name "cl"}}
            {{$buff.Write ": TColor"}}
        {{else if hasPrefix $el.Name "vk"}}
            {{$buff.Write ": Char"}}
        {{else if $isCur}}
            {{$buff.Write ": TCursor"}}
        {{else}}
            {{if or (or (hasPrefix .Name "id") (hasPrefix .Name "mr")) (hasPrefix .Name "CF_")}}
                {{$buff.Write ": u8"}}
            {{end}}
        {{end}}
        {{$buff.Write " = "}}
        {{if $isCur}}
            {{getConstVal2 $el.Value|$buff.Write}}
        {{else}}
            {{$buff.Write $el.Value}}
        {{end}}
        {{if not (isEmpty $el.Value2)}}
            {{$buff.Write " + " $el.Value2}}
        {{end}}
        {{$buff.Write ";"}}
        {{if not (isEmpty $el.Comment)}}
            {{$buff.Write " // " $el.Comment}}
        {{end}}
        {{$buff.Writeln}}

    {{else}}
        {{$buff.Writeln "##"}}
        {{$buff.Writeln "// " $el.Comment}}
    {{end}}
{{end}}


{{$buff.ToStr}}