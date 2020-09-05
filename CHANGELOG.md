## 0.0.1

* TODO: Describe initial release.

## 0.0.2

* Updated example
* Cleaned up dependencies

## 0.0.3

* Updated README.md

## 0.0.4

* Doc typos

## 0.0.5

* More documentation fixes

## 0.0.6

* CPUInfo stream added
* CPU freq index done by int (used to be String)

## 0.0.7

* Updated doc to remove IOS support

## 0.0.8
* Fixing broken package

## 0.0.9
* Pre-stable release

## 1.0.0
* First stable release
    - Frequency stream added
    - CPU info as blob
    - Individual metrics/cpu information 

## 1.0.1
* Minor bug fixes

## 1.0.2
* Added temperature value retrieval
* Now also allows to stream all of the CPU info (static data, such as min/max frequencies is cached, and therefore avoids any unnecessary I/O operations)

## 1.0.3
* Updated documentation

## 2.0.0-dev.1
* Major performance improvements. Removed event channel as data stream, as it was causing higher CPU usage.
* Updated example
 
## 2.0.0-dev.2
* package conflicts fix

## 2.0.0
* Major performance improvements.  
* CPU stream generated on the flutter side instead of native.
* Example updated