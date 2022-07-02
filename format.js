import get_files from './get_files.js'
import { exec } from 'child_process'

const files = get_files('.')
exec('npm run pg_format ' + files.join(' '))
console.log('pg_format files:')
console.log(files)
