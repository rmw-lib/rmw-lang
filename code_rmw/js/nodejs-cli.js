import { readFileSync } from 'fs'
import { ntDecode } from '@rmw/nestedtext'
import { walkRel } from '@rmw/walk'
import thisdir from '@rmw/thisdir'

import yargs from 'yargs/yargs'

import { hideBin } from 'yargs/helpers'
console.log(process.argv)