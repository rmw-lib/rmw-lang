import {join} from 'path'
import {readFileSync,writeFileSync} from 'fs'
import {ntDecode} from '@rmw/nestedtext'
import {walkRel} from '@rmw/walk'
import thisdir from '@rmw/thisdir'
import chokidar from 'chokidar'
import yargs from 'yargs'
import {hideBin} from 'yargs/helpers'
import 编译 from './编译'
