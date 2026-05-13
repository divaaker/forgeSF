public class pagedirections {

    public PageReference urlRedirection() {

          string url = 'http://www.google.ca/';

          PageReference page = new PageReference(url);
          page.setRedirect(true);
          return page;
    }
}