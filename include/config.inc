// vim: ts=3:filetype=pascal

(* Copyright (C) 2004-2009 Oleksandr Natalenko aka post-factum

   This program is free software; you can redistribute it and/or modify
   it under the terms of the Universal Program License as published by
   Oleksandr Natalenko aka post-factum; see file COPYING for details.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   You should have received a copy of the Universal Program
   License along with this program; if not, write to
   pfactum@gmail.com *)

//{$define config_debug}
(*if you specify this option, kernel will be compiled
  with a possibility to output debug messages. Use
  this option if you're developer, but remember that
  this will increase the size of kernel executable a
  little bit and make kernel slower*)

//{$define use_shared_memory}
(*EXPERIMENTAL: makes kernel and all processes use
  shared memory*)

//{$define standard_lock}
(*enables locking based on boolean operations. It's
  not atomic, but fast*)

{$define spin_lock}
(*enables fast spinlocking. It's atomic and responsible,
  but a bit slower than standard locking*)

//{$define spin_atomic_lock}
(*enables atomic spinlocking. It's almost the same as fast
  spinlocking, but more responsible and a bit slower*)

//{$define critical_lock}
(*EXPERIMENTAL: enables locking, based on critical sections.
  It's the most responsible way to lock, atomic, but it does
  not work now*)

//{$define collect_lock_statistic}
(*collects info about locking subsystem such as
  count of locks, waits and so on*)

const
	fsBufferSize = 512; (*buffer size for internal filecopy function*)
	kernelName = 'StreamOS'; (*OS name, cannot be changed*)
	kernelVersion = 'v0.21-rc3'; (*OS current version, changes often*)
	kernelCodeName = 'Sanka'; (*OS codename, changes each release*)

