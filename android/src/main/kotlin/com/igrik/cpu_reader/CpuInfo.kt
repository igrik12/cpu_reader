package com.igrik.cpu_reader


data class CpuInfo(val abi: String,
                   val numberOfCores: Int,
                   val currentFrequencies: MutableMap<Int, Long>,
                   val minMaxFrequencies: MutableMap<Int, Pair<Long, Long>>)