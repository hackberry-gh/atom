class CreateProcedures < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute(json_string)
    ActiveRecord::Base.connection.execute(json_int)
    ActiveRecord::Base.connection.execute(json_int_array)
    ActiveRecord::Base.connection.execute(json_float)
    ActiveRecord::Base.connection.execute(json_bool)
    ActiveRecord::Base.connection.execute(json_date)
    ActiveRecord::Base.connection.execute(json_increment)
    ActiveRecord::Base.connection.execute(json_decrement)
    ActiveRecord::Base.connection.execute(json_set_numeric)
    ActiveRecord::Base.connection.execute(json_set)
    ActiveRecord::Base.connection.execute(json_update)
    ActiveRecord::Base.connection.execute(json_push)
    ActiveRecord::Base.connection.execute(json_add_to_set)
    ActiveRecord::Base.connection.execute(json_pull)
    ActiveRecord::Base.connection.execute(json_data)
  end

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

  def json_set_numeric
    "CREATE or REPLACE FUNCTION
    json_set_numeric(data json, key text, value integer) RETURNS JSON AS $$

      var data = data;
      var value = value;

      data[key] = parseInt(value);

      return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end

  def json_set
    "CREATE or REPLACE FUNCTION
    json_set(data json, key text, value text) RETURNS JSON AS $$

      var data = data;
      var value = value;

      data[key] = value;

      return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end

  def json_update
    "CREATE or REPLACE FUNCTION
    json_update(data json, value text) RETURNS JSON AS $$

      var data = data;
      var forUpdate = value;

      for (k in forUpdate) {
        if ( data.hasOwnProperty(k) ) {
          data[k] = forUpdate[k];
        }
      }

      return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end

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

  def json_data
    "CREATE or REPLACE FUNCTION
    json_data(data json, fields text) RETURNS JSON AS $$

        var data = data;

        var _fields = fields.split(',');

        for (var key in data) {
          if (_fields.indexOf(key) == -1) delete data[key];
        }

      return JSON.stringify(data);

    $$ LANGUAGE plv8 STABLE STRICT;"
  end

end