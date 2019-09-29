<template>
  <div class="container">
    <div class="columns">
      <div class="column is-three-fifths">is-four-fifths</div>
      <div class="column">
        <div class="card">
          <header class="card-header">
            <p class="card-header-title">
              Domain Status
            </p>
          </header>
          <div class="card-content">
            <div class="content">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus nec iaculis mauris.
              <a href="#">@bulmaio</a>. <a href="#">#css</a> <a href="#">#responsive</a>
              <br>
              <time datetime="2016-1-1">11:09 PM - 1 Jan 2016</time>
            </div>
          </div>
          <footer class="card-footer">
            <a href="#" class="card-footer-item">Sync</a>
            <a href="#" class="card-footer-item">Config</a>
            <a href="#" class="card-footer-item">Metadata</a>
            <a href="#" class="card-footer-item">Sync History</a>
          </footer>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'Domain',
    data () {
      return {
        msg: 'Jira Team Metrics / Domain'
      }
    }
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  h1, h2 {
    font-weight: normal;
  }
  ul {
    list-style-type: none;
    padding: 0;
  }
  li {
    display: inline-block;
    margin: 0 10px;
  }
  a {
    color: #42b983;
  }
</style>
