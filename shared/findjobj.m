function [handles] = findjobj(varargin)
% FINDJOBJ - Stub replacement for the legacy findjobj utility.
%
% The original findjobj (by Yair Altman) used Java introspection to find
% underlying Java objects of MATLAB GUI components. This functionality has
% been removed from modern MATLAB versions (R2019b+).
%
% This stub returns empty values. All former callers in PeTTSy have been
% updated to use native MATLAB alternatives.
%
% The original file is preserved as findjobj_legacy.m for reference.

warning('findjobj:Deprecated', ...
    'findjobj is no longer functional in modern MATLAB. This is a stub that returns empty.');

handles = [];
