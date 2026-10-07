export default function Footer() {
  return (
    <footer className="site-footer">
      <div className="section-container">
        <div className="footer-main">
          <a href="/" className="footer-brand" aria-label="GIDYO home">
            GIDYO<span>.</span>
          </a>
          <p>Haiti, through local eyes.<br />A growing collective for more thoughtful travel.</p>
          <nav aria-label="Footer navigation" className="footer-links">
            <a href="#how-it-works">The approach</a>
            <a href="#guides-container">Perspectives</a>
            <a href="#services">Explore themes</a>
            <a href="#become-guide">For local guides</a>
          </nav>
        </div>
        <div className="footer-baseline">
          <span>© {new Date().getFullYear()} GIDYO</span>
          <span>Made for a more human way of seeing.</span>
        </div>
      </div>
    </footer>
  );
}
