// https://habr.com/ru/company/ruvds/blog/424969/
import * as fs from 'fs'
import * as path from 'path'

export default function get_files (dir, recursive = true) {
  let result = []
  const basename = path.basename(dir)
  const files = fs.readdirSync(dir)
  for (const i in files) {
    const filename = files[i]
    const filepath = dir + '/' + filename
    if (fs.statSync(filepath).isDirectory()) {
      if (recursive) {
        result = result.concat(get_files(filepath))
      }
    }
    else {
      const ext = path.extname(filename)
      if (ext !== '.sql') {
        continue
      }

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
