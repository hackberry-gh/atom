class CreateProcedures < ActiveRecord::Migration
  def change


    ActiveRecord::Base.connection.execute(json_string)
    ActiveRecord::Base.connection.execute(json_int)
    ActiveRecord::Base.connection.execute(json_int_array)
    ActiveRecord::Base.connection.execute(json_float)
    ActiveRecord::Base.connection.execute(json_bool)
    ActiveRecord::Base.connection.execute(json_date)

    # ActiveRecord::Base.connection.execute(json_data)
    ActiveRecord::Base.connection.execute(json_select)
    ActiveRecord::Base.connection.execute(json_select_all)

    ActiveRecord::Base.connection.execute(json_update)
    ActiveRecord::Base.connection.execute(json_push)
    ActiveRecord::Base.connection.execute(json_add_to_set)
    ActiveRecord::Base.connection.execute(json_pull)

    ActiveRecord::Base.connection.execute(json_increment)
    ActiveRecord::Base.connection.execute(json_decrement)
  end

  # POSTSQL START

  # READ

  # SELECT id, json_string(data,'name') FROM things WHERE json_string(data,'name') LIKE 'G%';
  def json_string
  "CREATE or REPLACE FUNCTION
  json_string(data json, key text) RETURNS TEXT AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }


    if (ret != undefined) {
      ret = ret.toString();
    }

    return ret;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_int(data,'person.id') FROM things WHERE json_int(data,'person.id') = 10;
  def json_int
  "CREATE or REPLACE FUNCTION
  json_int(data json, key text) RETURNS INT AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }

    ret = parseInt(ret);
    if (isNaN(ret)) ret = null;

    return ret;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, (json_int_array(data,'object.list') FROM things WHERE 10 = ANY/All (json_int_array(data,'object.list'))
  def json_int_array
  "CREATE or REPLACE FUNCTION
  json_int_array(data json, key text) RETURNS INT[] AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }

    if (! (ret instanceof Array)) {
      ret = [ret];
    }

    return ret;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_int(data,'count') FROM things WHERE json_int(data,'count') <= 99.9999;
  def json_float
  "CREATE or REPLACE FUNCTION
  json_float(data json, key text) RETURNS DOUBLE PRECISION AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }

    ret = parseFloat(ret);
    if (isNaN(ret)) ret = null;

    return ret;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_bool(data,'boolean') FROM things WHERE json_bool(data,'boolean') = false
  def json_bool
  "CREATE or REPLACE FUNCTION
  json_bool(data json, key text) RETURNS BOOLEAN AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }

    // if (ret != true || ret != false) ret = null;

    if (ret === true || ret === false) {
      return ret;
    }

    return null;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_date(data,'date') FROM things WHERE json_date(data,'date') <= NOW();
  def json_date
  "CREATE or REPLACE FUNCTION
  json_date(data json, key text) RETURNS TIMESTAMP AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }

    //ret = Date.parse(ret)
    //if (isNaN(ret)) ret = null;

    ret = new Date(ret)
    if (isNaN(ret.getTime())) ret = null;

    return ret;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_object(data,'name') FROM things WHERE json_object(data,'name') LIKE 'G%';
  def json_object
  "CREATE or REPLACE FUNCTION
  json_string(data json, key text) RETURNS JSON AS $$

    var ret = data;
    var keys = key.split('.')
    var len = keys.length;

    for (var i=0; i<len; ++i) {
      if (ret != undefined) ret = ret[keys[i]];
    }

    return ret;

  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_data(data, 'uuid,name') FROM things;
  # def json_data
  # "CREATE or REPLACE FUNCTION
  # json_data(data json, fields text) RETURNS JSON AS $$
  #
  #     var data = data;
  #
  #     var _fields = fields.split(',');
  #
  #     for (var key in data) {
  #       if (_fields.indexOf(key) == -1) delete data[key];
  #     }
  #
  #   return JSON.stringify(data);
  #
  # $$ LANGUAGE plv8 STABLE STRICT;"
  # end

  # SELECT id, json_select(data, 'i18n.en.title') FROM things;
  def json_select
  "CREATE OR REPLACE FUNCTION
  json_select(data json, selector text, parse boolean) RETURNS JSON AS $$
    if (data == null || selector == null || selector == '') {
      return null;
    }
    var names = selector.split('.');
    var result = names.reduce(function(previousValue, currentValue, index, array) {
      if (previousValue == null) {
        return null;
      } else {
        return previousValue[currentValue];
      }
    }, data);
    return parse ? JSON.stringify(result) : result;
  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # SELECT id, json_select(data, 'i18n.en.title,i18n.de.title') FROM things;
  def json_select_all
  "CREATE OR REPLACE FUNCTION
  json_select_all(data json, selectors text) RETURNS JSON AS $$
    var json_select = plv8.find_function('json_select');
    var selectorArray = selectors.replace(/\s+/g, '').split(',');
    var result = selectorArray.map(function(selector) { return json_select(data, selector); });
    return JSON.stringify(result);
  $$ LANGUAGE plv8 IMMUTABLE STRICT;"
  end

  # WRITE

  # UPDATE things SET data = json_update(data, {"i18n": {"en": {"title": "Article"}}});
  def json_update
  "CREATE or REPLACE FUNCTION
  json_update(data json, value json, sync boolean) RETURNS JSON AS $$

    var slice = Array.prototype.slice;
    var data = data;
    var forUpdate = value;
    var isObject = false;
    var sync = typeof(sync) === 'undefined' ? true : sync;

    var extend = function(obj,source) {
      if (source) {
        for (var prop in source) {
          obj[prop] = source[prop];
        }
      }
      return obj;
    };

    for (k in forUpdate) {

      if ( data.hasOwnProperty(k) ) {

        isObject = typeof(data[k]) === 'object' && typeof(forUpdate[k]) === 'object'
        data[k] = isObject && sync ? extend(data[k],forUpdate[k]) : forUpdate[k] ;

      }else{

        data[k] = forUpdate[k]

      }
    }

    return JSON.stringify(data);

  $$ LANGUAGE plv8 STABLE STRICT;"
  end

  # UPDATE things SET data = json_push(json_add_to_set(data, 'array', '101'), 'array', '99');
  # UPDATE things SET data = json_push(data, 'array', '10');
  def json_push
  "CREATE or REPLACE FUNCTION
  json_push(data json, key text, value json) RETURNS JSON AS $$

    var data = data;
    var value = value;

    var keys = key.split('.')
    var len = keys.length;

    var last_field = data;
    var field = data;

    for (var i=0; i<len; ++i) {
      last_field = field;
      if (field) field = field[keys[i]];
    }

    if (field) {
      field.push(value)
    } else {
      if (! (value instanceof Array)) {
        value = [value];
      }
      last_field[keys.pop()]= value;
    }

  return JSON.stringify(data);

  $$ LANGUAGE plv8 STABLE STRICT;"
  end

  # UPDATE things SET data = json_add_to_set(data, 'object.array', '10');
  def json_add_to_set
  "CREATE or REPLACE FUNCTION
  json_add_to_set(data json, key text, value json) RETURNS JSON AS $$

    var data = data;
    var value = value;

    var keys = key.split('.')
    var len = keys.length;

    var last_field = data;
    var field = data;

    for (var i=0; i<len; ++i) {
      last_field = field;
      if (field) field = field[keys[i]];
    }


    if (field && field.indexOf(value) == -1) {
      field.push(value)
    } else {
      if (! (value instanceof Array)) {
        value = [value];
      }
      last_field[keys.pop()]= value;
    }

  return JSON.stringify(data);

  $$ LANGUAGE plv8 STABLE STRICT;"
  end

  # UPDATE things SET data = json_pull(data, 'object.array', '10');
  def json_pull
  "CREATE or REPLACE FUNCTION
  json_pull(data json, key text, value json) RETURNS JSON AS $$

    var data = data;
    var value = value;

    var keys = key.split('.')
    var len = keys.length;

    var field = data;

    for (var i=0; i<len; ++i) {
      if (field) field = field[keys[i]];
    }

    if (field) {
      var idx = field.indexOf(value);

      if (idx != -1) {
        field.slice(idx);
      }
    }


  return JSON.stringify(data);

  $$ LANGUAGE plv8 STABLE STRICT;"
  end


  # POSTSQL END
  # https://github.com/tobyhede/postsql/blob/master/postsql.sql

  def json_set
    "CREATE or REPLACE FUNCTION
    json_set(data json, key text, value text) RETURNS JSON AS $$

      var data = data;
      var value = value;

      data[key] = value;

      return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end

  def json_increment
    "CREATE or REPLACE FUNCTION
    json_increment(data json, key text, value integer) RETURNS JSON AS $$

      var data = data;
      var value = value;

      data[key] += parseInt(value);

      return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end


  def json_decrement
    "CREATE or REPLACE FUNCTION
    json_decrement(data json, key text, value integer) RETURNS JSON AS $$

    var data = data;
    var value = value;

    data[key] -= parseInt(value);

    return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end


end