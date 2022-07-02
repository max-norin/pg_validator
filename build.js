// https://habr.com/ru/company/ruvds/blog/424969/
import * as fs from 'fs'
import * as path from 'path'

const getFiles = function (dir, recursive = true) {
  let result = []
  const basename = path.basename(dir)
  const files = fs.readdirSync(dir)
  for (const i in files) {
    const filename = files[i]
    const ext = path.extname(filename)
    if (ext !== '.sql') {
      continue
    }
    const filepath = dir + '/' + filename
    if (fs.statSync(filepath).isDirectory()) {
      if (recursive) {
        result = result.concat(getFiles(filepath))
      }
    }
    else {
      if (path.basename(filename, ext) === basename) {
        result.unshift(filepath)
      }
      else {
        result.push(filepath)
      }
    }
  }
  return result
}

const files = [
  ...getFiles('./helpers'),
  ...getFiles('./types', false),
  ...getFiles('./types/set'),
  ...getFiles('./types/constraint_def'),
  ...getFiles('./rules'),
  ...getFiles('./domains'),
  ...getFiles('./validate'),
]

let content = ''
for (const i in files) {
  const filepath = files[i]
  const data = fs.readFileSync(filepath, 'utf8')

  const title = path.parse(filepath).name.toUpperCase()
  const header =
    `/*
=================== ${title} =================== 
*/\n`
  content += header + data
}

const version = process.env.npm_package_version
const filepath = `./dist/pg_validate--${version}.sql`
fs.writeFileSync(filepath, content, 'utf8')
