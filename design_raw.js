class Component extends DCLogic {
  EVENTS = [
    {
      id: 1,
      title: "TECHNORITI '25",
      short: "TECHNO\nRITI",
      subtitle: "NIT Raipur's Annual Tech & Cultural Fest",
      category: "College Fest",
      color: "#2D7DFF",
      dark: "#050D1F",
      date: "FRI–SUN, 25–27 JUL",
      time: "10 AM ONWARDS",
      venue: "NIT Raipur Campus",
      organizer: "NIT Raipur",
      description:
        "Three days of tech talks, hackathons, music and cultural performances. 50+ college teams from across India. Open to all.",
      interested: 847,
      tags: ["Tech", "Music", "College"],
      weekend: true,
      hot: true,
      trending: true,
    },
    {
      id: 2,
      title: "OPEN MIC NIGHT",
      short: "OPEN\nMIC",
      subtitle: "Raipur's favourite open mic is back",
      category: "Music",
      color: "#FF2D8D",
      dark: "#130008",
      date: "SAT, 26 JUL",
      time: "7:00 PM",
      venue: "Café Canvas, GE Road",
      organizer: "Café Canvas",
      description:
        "5-minute slots. Poetry, music, comedy, spoken word. Sign up at the door. Come alone, leave with friends.",
      interested: 234,
      tags: ["Music", "Café", "Art"],
      weekend: true,
      hot: true,
      trending: false,
    },
    {
      id: 3,
      title: "SUNDAY FARMERS MARKET",
      short: "FARMERS\nMKT",
      subtitle: "Local produce, handmade goods & good vibes",
      category: "Market",
      color: "#A3FF12",
      dark: "#051000",
      date: "SUN, 27 JUL",
      time: "7 AM – 12 PM",
      venue: "Marine Drive, Telibandha",
      organizer: "Raipur Organic Collective",
      description:
        "35+ local vendors. Fresh produce, artisan goods, street food. Bring your tote bags.",
      interested: 389,
      tags: ["Market", "Food", "Outdoor"],
      weekend: true,
      hot: false,
      trending: true,
    },
    {
      id: 4,
      title: "CIRCUIT: TECHNO NIGHT",
      short: "CIRCUIT",
      subtitle: "Underground electronic music, all night",
      category: "Nightlife",
      color: "#7B2DFF",
      dark: "#0A0015",
      date: "FRI, 25 JUL",
      time: "10 PM – 4 AM",
      venue: "Club Circuit, Shankar Nagar",
      organizer: "Circuit Events",
      description:
        "Four DJs. One floor. Zero compromises. Dress code: all black. 18+ only.",
      interested: 567,
      tags: ["Nightlife", "Electronic", "18+"],
      weekend: true,
      hot: true,
      trending: true,
    },
    {
      id: 5,
      title: "PHOTO WALK: OLD CITY",
      short: "PHOTO\nWALK",
      subtitle: "Street photography through old Raipur",
      category: "Photography",
      color: "#FF7A00",
      dark: "#150800",
      date: "SUN, 27 JUL",
      time: "6:00 AM",
      venue: "Meeting at Budhapara Lake",
      organizer: "Raipur Photography Club",
      description:
        "2-hour guided walk through old city. Any camera welcome — phone, film, DSLR. Discuss shots over chai after.",
      interested: 143,
      tags: ["Photography", "Outdoor", "Community"],
      weekend: true,
      hot: false,
      trending: false,
    },
    {
      id: 6,
      title: "STARTUP CHAI #12",
      short: "STARTUP\nCHAI",
      subtitle: "Monthly founders meetup — Raipur edition",
      category: "Startup",
      color: "#FFD400",
      dark: "#111000",
      date: "WED, 30 JUL",
      time: "6:30 PM",
      venue: "91Springboard, Raipur",
      organizer: "Startup Raipur",
      description:
        "Casual meetup for founders, builders, and curious minds. Lightning talks + chai. No pitch decks.",
      interested: 201,
      tags: ["Startup", "Networking"],
      weekend: false,
      hot: false,
      trending: false,
    },
    {
      id: 7,
      title: "FLOWER EXPO 2025",
      short: "FLOWER\nEXPO",
      subtitle: "Annual flower & garden exhibition",
      category: "Exhibition",
      color: "#FF2D8D",
      dark: "#130008",
      date: "SAT–SUN, 26–27 JUL",
      time: "9 AM – 6 PM",
      venue: "Science College Ground",
      organizer: "Raipur Municipal Corporation",
      description:
        "Hundreds of plant varieties, gardening workshops, and live demonstrations. Family-friendly.",
      interested: 312,
      tags: ["Garden", "Family", "Exhibition"],
      weekend: true,
      hot: false,
      trending: false,
    },
  ];

  COMMUNITIES = [
    {
      id: 1,
      name: "Photography",
      emoji: "📸",
      color: "#FF7A00",
      members: 1240,
      posts: 89,
      description:
        "Raipur's photography community. Walk, shoot, discuss, grow.",
    },
    {
      id: 2,
      name: "Coffee Lovers",
      emoji: "☕",
      color: "#FF2D8D",
      members: 876,
      posts: 234,
      description: "The best cafés, brews, and coffee culture in Raipur.",
    },
    {
      id: 3,
      name: "Gaming",
      emoji: "🎮",
      color: "#7B2DFF",
      members: 2100,
      posts: 567,
      description: "Mobile, PC, console — tournaments, team-ups, reviews.",
    },
    {
      id: 4,
      name: "Foodies",
      emoji: "🍜",
      color: "#FF7A00",
      members: 1890,
      posts: 891,
      description: "Raipur's food scene, reviewed and discovered daily.",
    },
    {
      id: 5,
      name: "Music",
      emoji: "🎵",
      color: "#FF2D8D",
      members: 1456,
      posts: 345,
      description: "Gigs, rehearsals, collabs, and music discourse.",
    },
    {
      id: 6,
      name: "Cycling",
      emoji: "🚴",
      color: "#A3FF12",
      members: 567,
      posts: 123,
      description: "Morning rides, routes, gear talk, and cycling events.",
    },
    {
      id: 7,
      name: "Books",
      emoji: "📚",
      color: "#2D7DFF",
      members: 789,
      posts: 234,
      description: "Book club, recommendations, and literary events.",
    },
    {
      id: 8,
      name: "Startups",
      emoji: "🚀",
      color: "#FFD400",
      members: 1123,
      posts: 456,
      description: "Founders, builders, and startup culture in Raipur.",
    },
    {
      id: 9,
      name: "Art",
      emoji: "🎨",
      color: "#7B2DFF",
      members: 934,
      posts: 178,
      description: "Visual art, exhibitions, sketching, and creative events.",
    },
    {
      id: 10,
      name: "Fitness",
      emoji: "💪",
      color: "#A3FF12",
      members: 1567,
      posts: 678,
      description: "Training, nutrition, and fitness events in the city.",
    },
    {
      id: 11,
      name: "Theatre",
      emoji: "🎭",
      color: "#FF2D8D",
      members: 432,
      posts: 89,
      description: "Plays, improv, and performance arts.",
    },
    {
      id: 12,
      name: "Pets",
      emoji: "🐾",
      color: "#FF7A00",
      members: 654,
      posts: 156,
      description: "Pet owners, meetups, and animal-friendly spots.",
    },
  ];

  INTERESTS = [
    { id: "photography", label: "Photography", emoji: "📸" },
    { id: "gaming", label: "Gaming", emoji: "🎮" },
    { id: "food", label: "Food", emoji: "🍜" },
    { id: "music", label: "Music", emoji: "🎵" },
    { id: "fitness", label: "Fitness", emoji: "💪" },
    { id: "books", label: "Books", emoji: "📚" },
    { id: "coffee", label: "Coffee", emoji: "☕" },
    { id: "startups", label: "Startups", emoji: "🚀" },
    { id: "art", label: "Art", emoji: "🎨" },
    { id: "cycling", label: "Cycling", emoji: "🚴" },
    { id: "theatre", label: "Theatre", emoji: "🎭" },
    { id: "pets", label: "Pets", emoji: "🐾" },
  ];

  POSTS = [
    {
      id: 1,
      cid: 1,
      author: "Arjun M.",
      av: "🧔",
      time: "2h ago",
      text: "Morning light at Budhapara was incredible today. Who's joining the walk on Sunday?",
      likes: 24,
      comments: 8,
      img: false,
    },
    {
      id: 2,
      cid: 1,
      author: "Priya S.",
      av: "👩",
      time: "5h ago",
      text: "Finally got my Fujifilm XT-5. First proper street shots this weekend. Drop your camera settings tips!",
      likes: 47,
      comments: 15,
      img: false,
    },
    {
      id: 3,
      cid: 1,
      author: "Rahul K.",
      av: "👨",
      time: "1d ago",
      text: "Posting our Photography Walk results from last Sunday. 12 of us, 400+ shots, 3 hours. Best morning of the month.",
      likes: 89,
      comments: 23,
      img: true,
    },
    {
      id: 4,
      cid: 2,
      author: "Neha R.",
      av: "👩‍🦱",
      time: "1h ago",
      text: "Tried the new pour-over at Café Canvas. Honestly better than Third Wave. Change my mind.",
      likes: 31,
      comments: 12,
      img: false,
    },
    {
      id: 5,
      cid: 3,
      author: "Dev P.",
      av: "🧑",
      time: "30m ago",
      text: "Anyone interested in forming a Valorant team for the upcoming tournament? Need 3 more. Comment your rank.",
      likes: 67,
      comments: 34,
      img: false,
    },
    {
      id: 6,
      cid: 2,
      author: "Simran T.",
      av: "👧",
      time: "3h ago",
      text: "Annapurna Café on Pandri road has a rooftop now. Quiet, good WiFi, great filter coffee. Our new community spot.",
      likes: 55,
      comments: 18,
      img: false,
    },
  ];

  NOTIFS = [
    {
      id: 1,
      icon: "🔥",
      title: "Circuit: Techno Night is tomorrow!",
      body: "You marked as interested. Starts 10 PM. All black dress code.",
      time: "2h ago",
      color: "#7B2DFF",
    },
    {
      id: 2,
      icon: "📸",
      title: "New post in Photography",
      body: 'Priya S.: "Finally got my Fujifilm XT-5..."',
      time: "5h ago",
      color: "#FF7A00",
    },
    {
      id: 3,
      icon: "📅",
      title: "NIT Technoriti starts Friday!",
      body: "847 people are interested. See you there.",
      time: "1d ago",
      color: "#2D7DFF",
    },
    {
      id: 4,
      icon: "✨",
      title: "New: Flower Expo 2025",
      body: "Added to events. Sat–Sun at Science College Ground.",
      time: "2d ago",
      color: "#FF2D8D",
    },
    {
      id: 5,
      icon: "👥",
      title: "Gaming community posted",
      body: 'Dev P.: "Anyone for a Valorant team? Need 3 more."',
      time: "3d ago",
      color: "#7B2DFF",
    },
  ];

  ICOLORS = ["#FF2D8D", "#A3FF12", "#2D7DFF", "#7B2DFF", "#FF7A00", "#FFD400"];

  state = {
    screen: "home",
    prevScreen: null,
    tab: "home",
    selEv: null,
    selComm: null,
    rsvpd: new Set(),
    joined: new Set([1, 3]),
    saved: new Set([2]),
    liked: new Set([1]),
    evFilter: "all",
    commTab: "posts",
    nameInput: "Riya",
    userName: "Riya Sharma",
    selInterests: new Set(["photography", "music", "coffee", "gaming", "art"]),
    searchQ: "",
  };

  componentDidMount() {
    this._t = setTimeout(() => {
      if (this.state.screen === "splash")
        this.setState({ screen: "onboarding-name" });
    }, 2800);
  }
  componentWillUnmount() {
    clearTimeout(this._t);
  }

  nav(screen, tab) {
    this.setState({
      prevScreen: this.state.screen,
      screen,
      ...(tab ? { tab } : {}),
    });
  }
  goBack() {
    const { prevScreen, tab } = this.state;
    this.setState({ screen: prevScreen || tab || "home", prevScreen: null });
  }
  toggleRsvp(id) {
    const s = new Set(this.state.rsvpd);
    s.has(id) ? s.delete(id) : s.add(id);
    this.setState({ rsvpd: s });
  }
  toggleJoin(id) {
    const s = new Set(this.state.joined);
    s.has(id) ? s.delete(id) : s.add(id);
    this.setState({ joined: s });
  }
  toggleSave(id) {
    const s = new Set(this.state.saved);
    s.has(id) ? s.delete(id) : s.add(id);
    this.setState({ saved: s });
  }
  toggleLike(id) {
    const s = new Set(this.state.liked);
    s.has(id) ? s.delete(id) : s.add(id);
    this.setState({ liked: s });
  }

  e(...a) {
    return React.createElement(...a);
  }

  // ─── HELPERS ───────────────────────────────────────────────
  sectionHeader(title, color, onAll) {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        style: {
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "22px 20px 12px",
        },
      },
      e(
        "span",
        {
          style: {
            fontFamily: "Bebas Neue,sans-serif",
            fontSize: 19,
            color,
            letterSpacing: "0.08em",
            lineHeight: 1,
          },
        },
        title,
      ),
      onAll &&
        e(
          "button",
          {
            onClick: onAll,
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 12,
              fontWeight: 600,
              color: "#A7A7B3",
              background: "none",
              border: "none",
              cursor: "pointer",
              letterSpacing: "0.04em",
            },
          },
          "SEE ALL →",
        ),
    );
  }

  backBtn(onClick) {
    const e = this.e.bind(this);
    return e(
      "button",
      {
        onClick,
        style: {
          width: 38,
          height: 38,
          background: "rgba(0,0,0,0.55)",
          backdropFilter: "blur(10px)",
          border: "1px solid rgba(255,255,255,0.1)",
          borderRadius: 12,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
          flexShrink: 0,
        },
      },
      e(
        "svg",
        { width: 20, height: 20, viewBox: "0 0 24 24", fill: "white" },
        e("path", {
          d: "M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z",
        }),
      ),
    );
  }

  posterCard(ev) {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        key: ev.id,
        onClick: () => {
          this.setState({ selEv: ev });
          this.nav("event-detail");
        },
        style: {
          flexShrink: 0,
          width: 196,
          height: 290,
          borderRadius: 18,
          overflow: "hidden",
          background: ev.dark,
          border: `1px solid ${ev.color}22`,
          position: "relative",
          cursor: "pointer",
        },
      },
      e("div", { style: { height: 3, background: ev.color } }),
      e("div", {
        style: {
          position: "absolute",
          top: -10,
          right: -20,
          width: 120,
          height: 120,
          background: ev.color,
          borderRadius: "50%",
          filter: "blur(45px)",
          opacity: 0.35,
        },
      }),
      e("div", {
        style: {
          position: "absolute",
          bottom: -20,
          left: -20,
          width: 80,
          height: 80,
          background: ev.color,
          borderRadius: "50%",
          filter: "blur(30px)",
          opacity: 0.15,
        },
      }),
      e(
        "div",
        {
          style: {
            padding: 14,
            height: "100%",
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-between",
          },
        },
        e(
          "div",
          {
            style: {
              background: ev.color + "22",
              border: `1px solid ${ev.color}44`,
              borderRadius: 6,
              padding: "3px 8px",
              alignSelf: "flex-start",
            },
          },
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 10,
                fontWeight: 700,
                color: ev.color,
                letterSpacing: "0.1em",
              },
            },
            ev.category.toUpperCase(),
          ),
        ),
        e(
          "div",
          {},
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 30,
                color: "#fff",
                lineHeight: 0.9,
                letterSpacing: "-0.01em",
                marginBottom: 8,
                textShadow: `0 0 30px ${ev.color}80`,
              },
            },
            ev.title,
          ),
          e(
            "div",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 11,
                color: "#A7A7B3",
                marginBottom: 2,
              },
            },
            ev.date,
          ),
          e(
            "div",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 11,
                color: "#A7A7B3",
                overflow: "hidden",
                textOverflow: "ellipsis",
                whiteSpace: "nowrap",
              },
            },
            ev.venue,
          ),
          e(
            "div",
            {
              style: {
                marginTop: 10,
                display: "flex",
                alignItems: "center",
                gap: 5,
              },
            },
            e("div", {
              style: {
                width: 6,
                height: 6,
                background: ev.color,
                borderRadius: "50%",
                animation: "blink 2s ease-in-out infinite",
              },
            }),
            e(
              "span",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 11,
                  fontWeight: 600,
                  color: ev.color,
                },
              },
              `${ev.interested} interested`,
            ),
          ),
        ),
      ),
    );
  }

  smallCard(ev) {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        key: ev.id,
        onClick: () => {
          this.setState({ selEv: ev });
          this.nav("event-detail");
        },
        style: {
          flexShrink: 0,
          width: 160,
          borderRadius: 14,
          overflow: "hidden",
          background: "#141419",
          border: `1px solid ${ev.color}30`,
          cursor: "pointer",
        },
      },
      e("div", { style: { height: 3, background: ev.color } }),
      e(
        "div",
        { style: { padding: "12px 14px 14px" } },
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 10,
              fontWeight: 700,
              color: ev.color,
              letterSpacing: "0.12em",
              marginBottom: 5,
            },
          },
          ev.category.toUpperCase(),
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Bebas Neue,sans-serif",
              fontSize: 17,
              color: "#fff",
              lineHeight: 1.05,
              letterSpacing: "0.03em",
              marginBottom: 7,
            },
          },
          ev.title,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              color: "#A7A7B3",
            },
          },
          ev.date,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              color: "#A7A7B3",
              marginTop: 1,
            },
          },
          ev.time,
        ),
      ),
    );
  }

  commChip(comm) {
    const e = this.e.bind(this);
    const joined = this.state.joined.has(comm.id);
    return e(
      "div",
      {
        key: comm.id,
        onClick: () => {
          this.setState({ selComm: comm, commTab: "posts" });
          this.nav("community-detail");
        },
        style: {
          flexShrink: 0,
          width: 126,
          borderRadius: 14,
          background: "#141419",
          border: `1px solid ${joined ? comm.color + "60" : "#2C2C36"}`,
          padding: 14,
          cursor: "pointer",
        },
      },
      e("div", { style: { fontSize: 28, marginBottom: 8 } }, comm.emoji),
      e(
        "div",
        {
          style: {
            fontFamily: "'Space Grotesk',sans-serif",
            fontSize: 13,
            fontWeight: 700,
            color: "#fff",
            marginBottom: 2,
          },
        },
        comm.name,
      ),
      e(
        "div",
        {
          style: {
            fontFamily: "'Space Grotesk',sans-serif",
            fontSize: 11,
            color: "#A7A7B3",
          },
        },
        `${(comm.members / 1000).toFixed(1)}K members`,
      ),
      joined &&
        e(
          "div",
          {
            style: {
              marginTop: 7,
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 10,
              fontWeight: 600,
              color: comm.color,
              letterSpacing: "0.08em",
            },
          },
          "✓ JOINED",
        ),
    );
  }

  listCard(ev) {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        key: ev.id,
        onClick: () => {
          this.setState({ selEv: ev });
          this.nav("event-detail");
        },
        style: {
          display: "flex",
          gap: 12,
          alignItems: "center",
          background: "#141419",
          borderRadius: 14,
          padding: "13px 14px",
          border: "1px solid #2C2C36",
          cursor: "pointer",
          marginBottom: 10,
        },
      },
      e(
        "div",
        {
          style: {
            width: 48,
            height: 48,
            borderRadius: 12,
            background: ev.dark,
            border: `1px solid ${ev.color}40`,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            flexShrink: 0,
          },
        },
        e(
          "div",
          {
            style: {
              fontFamily: "Bebas Neue,sans-serif",
              fontSize: 10,
              color: ev.color,
              textAlign: "center",
              lineHeight: 1.2,
              letterSpacing: "0.04em",
            },
          },
          ev.short || ev.category,
        ),
      ),
      e(
        "div",
        { style: { flex: 1, minWidth: 0 } },
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 14,
              fontWeight: 700,
              color: "#fff",
              marginBottom: 2,
              overflow: "hidden",
              textOverflow: "ellipsis",
              whiteSpace: "nowrap",
            },
          },
          ev.title,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              color: "#A7A7B3",
            },
          },
          `${ev.date} · ${ev.venue.split(",")[0]}`,
        ),
      ),
      e(
        "div",
        { style: { flexShrink: 0, textAlign: "center" } },
        e("div", {
          style: {
            fontFamily: "Bebas Neue,sans-serif",
            fontSize: 14,
            color: ev.color,
          },
        }),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 10,
              color: "#A7A7B3",
            },
          },
          `${ev.interested}`,
        ),
      ),
    );
  }

  eventGridCard(ev) {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        key: ev.id,
        onClick: () => {
          this.setState({ selEv: ev });
          this.nav("event-detail");
        },
        style: {
          borderRadius: 16,
          overflow: "hidden",
          background: "#141419",
          border: `1px solid ${ev.color}25`,
          cursor: "pointer",
        },
      },
      e(
        "div",
        {
          style: {
            height: 100,
            background: ev.dark,
            position: "relative",
            overflow: "hidden",
          },
        },
        e("div", {
          style: {
            position: "absolute",
            top: -20,
            right: -20,
            width: 80,
            height: 80,
            background: ev.color,
            borderRadius: "50%",
            opacity: 0.35,
            filter: "blur(20px)",
          },
        }),
        e(
          "div",
          {
            style: {
              position: "absolute",
              top: 8,
              right: 8,
              background: ev.color,
              borderRadius: 6,
              padding: "2px 6px",
            },
          },
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 9,
                fontWeight: 700,
                color:
                  ev.color === "#A3FF12" || ev.color === "#FFD400"
                    ? "#0B0B0F"
                    : "#fff",
              },
            },
            ev.category.toUpperCase(),
          ),
        ),
        e(
          "div",
          { style: { position: "absolute", bottom: 8, left: 10, right: 8 } },
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 20,
                color: "#fff",
                lineHeight: 0.95,
                letterSpacing: "-0.01em",
              },
            },
            ev.short || ev.title,
          ),
        ),
      ),
      e(
        "div",
        { style: { padding: "10px 12px 13px" } },
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 12,
              fontWeight: 700,
              color: "#fff",
              marginBottom: 3,
              lineHeight: 1.3,
            },
          },
          ev.title,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              color: "#A7A7B3",
            },
          },
          ev.date,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              color: "#A7A7B3",
              overflow: "hidden",
              textOverflow: "ellipsis",
              whiteSpace: "nowrap",
            },
          },
          ev.venue,
        ),
        e(
          "div",
          {
            style: {
              marginTop: 8,
              display: "flex",
              alignItems: "center",
              gap: 4,
            },
          },
          e("div", {
            style: {
              width: 5,
              height: 5,
              background: ev.color,
              borderRadius: "50%",
            },
          }),
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 10,
                fontWeight: 600,
                color: ev.color,
              },
            },
            `${ev.interested}`,
          ),
        ),
      ),
    );
  }

  commCard(comm) {
    const e = this.e.bind(this);
    const joined = this.state.joined.has(comm.id);
    return e(
      "div",
      {
        key: comm.id,
        onClick: () => {
          this.setState({ selComm: comm, commTab: "posts" });
          this.nav("community-detail");
        },
        style: {
          borderRadius: 16,
          background: "#141419",
          border: `1px solid ${joined ? comm.color + "55" : "#2C2C36"}`,
          overflow: "hidden",
          cursor: "pointer",
        },
      },
      e("div", { style: { height: 4, background: comm.color } }),
      e(
        "div",
        { style: { padding: 14 } },
        e("div", { style: { fontSize: 30, marginBottom: 8 } }, comm.emoji),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 14,
              fontWeight: 700,
              color: "#fff",
              marginBottom: 4,
            },
          },
          comm.name,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              color: "#A7A7B3",
              lineHeight: 1.4,
              display: "-webkit-box",
              WebkitLineClamp: 2,
              WebkitBoxOrient: "vertical",
              overflow: "hidden",
              marginBottom: 10,
            },
          },
          comm.description,
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
            },
          },
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 11,
                color: "#A7A7B3",
              },
            },
            `${comm.members >= 1000 ? (comm.members / 1000).toFixed(1) + "K" : comm.members} members`,
          ),
          joined &&
            e(
              "div",
              {
                style: {
                  width: 20,
                  height: 20,
                  background: comm.color,
                  borderRadius: 6,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                },
              },
              e(
                "svg",
                {
                  width: 12,
                  height: 12,
                  viewBox: "0 0 24 24",
                  fill:
                    comm.color === "#A3FF12" || comm.color === "#FFD400"
                      ? "#0B0B0F"
                      : "#fff",
                },
                e("path", {
                  d: "M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z",
                }),
              ),
            ),
        ),
      ),
    );
  }

  postCard(post, comm) {
    const e = this.e.bind(this);
    const liked = this.state.liked.has(post.id);
    return e(
      "div",
      {
        key: post.id,
        style: {
          background: "#141419",
          borderRadius: 16,
          padding: 16,
          marginBottom: 12,
          border: "1px solid #2C2C36",
        },
      },
      e(
        "div",
        {
          style: {
            display: "flex",
            alignItems: "center",
            gap: 10,
            marginBottom: 12,
          },
        },
        e(
          "div",
          {
            style: {
              width: 36,
              height: 36,
              background: comm.color + "30",
              borderRadius: "50%",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 18,
              border: `1px solid ${comm.color}30`,
            },
          },
          post.av,
        ),
        e(
          "div",
          {},
          e(
            "div",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 13,
                fontWeight: 700,
                color: "#fff",
              },
            },
            post.author,
          ),
          e(
            "div",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 11,
                color: "#A7A7B3",
              },
            },
            post.time,
          ),
        ),
      ),
      e(
        "div",
        {
          style: {
            fontFamily: "'Space Grotesk',sans-serif",
            fontSize: 14,
            color: "#fff",
            lineHeight: 1.65,
            marginBottom: 12,
          },
        },
        post.text,
      ),
      post.img &&
        e(
          "div",
          {
            style: {
              height: 140,
              background: "#0B0B0F",
              borderRadius: 12,
              marginBottom: 12,
              border: "1px solid #2C2C36",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              overflow: "hidden",
            },
          },
          e(
            "div",
            { style: { textAlign: "center", color: "#A7A7B3" } },
            e("div", { style: { fontSize: 28, marginBottom: 4 } }, "🖼"),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 12,
                },
              },
              "Photo",
            ),
          ),
        ),
      e(
        "div",
        { style: { display: "flex", gap: 16 } },
        e(
          "button",
          {
            onClick: () => this.toggleLike(post.id),
            style: {
              display: "flex",
              alignItems: "center",
              gap: 6,
              background: "none",
              border: "none",
              cursor: "pointer",
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 13,
              color: liked ? comm.color : "#A7A7B3",
              transition: "color 0.15s",
            },
          },
          "♥",
          ` ${liked ? post.likes + 1 : post.likes}`,
        ),
        e(
          "button",
          {
            style: {
              display: "flex",
              alignItems: "center",
              gap: 6,
              background: "none",
              border: "none",
              cursor: "pointer",
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 13,
              color: "#A7A7B3",
            },
          },
          "💬",
          ` ${post.comments}`,
        ),
      ),
    );
  }

  // ─── SCREENS ─────────────────────────────────────────────────
  renderSplash() {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        onClick: () => this.setState({ screen: "onboarding-name" }),
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
          overflow: "hidden",
        },
      },
      e("div", {
        style: {
          position: "absolute",
          inset: 0,
          background:
            "radial-gradient(circle at 50% 40%, rgba(255,45,141,0.18) 0%, transparent 55%), radial-gradient(circle at 80% 80%, rgba(163,255,18,0.1) 0%, transparent 45%)",
        },
      }),
      e("div", {
        style: {
          position: "absolute",
          inset: 0,
          backgroundImage:
            "repeating-linear-gradient(0deg,transparent,transparent 2px,rgba(255,255,255,0.018) 2px,rgba(255,255,255,0.018) 4px)",
          pointerEvents: "none",
        },
      }),
      e(
        "div",
        { style: { zIndex: 1, textAlign: "center" } },
        e(
          "div",
          {
            style: {
              display: "inline-flex",
              alignItems: "center",
              gap: 7,
              background: "rgba(255,45,141,0.14)",
              border: "1px solid rgba(255,45,141,0.35)",
              borderRadius: 100,
              padding: "5px 14px",
              marginBottom: 28,
            },
          },
          e("div", {
            style: {
              width: 6,
              height: 6,
              background: "#FF2D8D",
              borderRadius: "50%",
              animation: "blink 1s ease-in-out infinite",
            },
          }),
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 11,
                fontWeight: 700,
                color: "#FF2D8D",
                letterSpacing: "0.18em",
              },
            },
            "RAIPUR",
          ),
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 100,
              color: "#fff",
              lineHeight: 0.85,
              letterSpacing: "-0.02em",
              animation: "glitch 4s ease-in-out infinite 1s",
            },
          },
          "HATRI",
        ),
        e(
          "div",
          {
            style: {
              marginTop: 18,
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 12,
              fontWeight: 600,
              color: "#A7A7B3",
              letterSpacing: "0.28em",
            },
          },
          "YOUR CITY. YOUR SCENE.",
        ),
        e(
          "div",
          {
            style: {
              marginTop: 44,
              display: "flex",
              gap: 8,
              justifyContent: "center",
            },
          },
          ...[0, 1, 2].map((i) =>
            e("div", {
              key: i,
              style: {
                width: 6,
                height: 6,
                borderRadius: "50%",
                background:
                  i === 0 ? "#FF2D8D" : i === 1 ? "#A3FF12" : "#2D7DFF",
                animation: `blink 1.2s ease-in-out ${i * 0.3}s infinite`,
              },
            }),
          ),
        ),
      ),
    );
  }

  renderOnboardingName() {
    const e = this.e.bind(this);
    const s = this.state;
    const valid = s.nameInput.trim().length > 0;
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          padding: "56px 28px 40px",
          animation: "scaleIn 0.3s ease",
        },
      },
      e(
        "div",
        { style: { display: "flex", gap: 4, marginBottom: 48 } },
        e("div", {
          style: { height: 3, flex: 1, background: "#FF2D8D", borderRadius: 2 },
        }),
        e("div", {
          style: { height: 3, flex: 1, background: "#2C2C36", borderRadius: 2 },
        }),
        e("div", {
          style: { height: 3, flex: 1, background: "#2C2C36", borderRadius: 2 },
        }),
      ),
      e(
        "div",
        {
          style: {
            flex: 1,
            display: "flex",
            flexDirection: "column",
            justifyContent: "center",
          },
        },
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              fontWeight: 700,
              color: "#FF2D8D",
              letterSpacing: "0.22em",
              marginBottom: 16,
            },
          },
          "01 / NAME",
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 56,
              color: "#fff",
              lineHeight: 0.9,
              letterSpacing: "-0.01em",
              marginBottom: 4,
            },
          },
          `WHAT'S`,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 56,
              color: "#fff",
              lineHeight: 0.9,
              letterSpacing: "-0.01em",
              marginBottom: 4,
            },
          },
          "YOUR",
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 56,
              color: "#A3FF12",
              lineHeight: 0.9,
              letterSpacing: "-0.01em",
              marginBottom: 44,
            },
          },
          "NAME?",
        ),
        e(
          "div",
          {
            style: {
              borderBottom: `2px solid ${valid ? "#FF2D8D" : "#2C2C36"}`,
              paddingBottom: 10,
              marginBottom: 8,
              transition: "border-color 0.2s",
            },
          },
          e("input", {
            type: "text",
            placeholder: "Your name...",
            value: s.nameInput,
            onChange: (ev) => this.setState({ nameInput: ev.target.value }),
            autoFocus: true,
            style: {
              width: "100%",
              background: "none",
              border: "none",
              outline: "none",
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 28,
              fontWeight: 600,
              color: "#fff",
              caretColor: "#FF2D8D",
            },
          }),
        ),
      ),
      e(
        "button",
        {
          onClick: () => {
            if (valid)
              this.setState({
                screen: "onboarding-interests",
                userName: s.nameInput.trim(),
              });
          },
          style: {
            width: "100%",
            padding: "18px",
            background: valid ? "#FF2D8D" : "#1D1D24",
            border: "none",
            borderRadius: 16,
            fontFamily: "'Space Grotesk',sans-serif",
            fontSize: 15,
            fontWeight: 700,
            color: valid ? "#fff" : "#A7A7B3",
            cursor: valid ? "pointer" : "default",
            letterSpacing: "0.06em",
            transition: "all 0.2s",
          },
        },
        "CONTINUE →",
      ),
    );
  }

  renderOnboardingInterests() {
    const e = this.e.bind(this);
    const s = this.state;
    const enough = s.selInterests.size >= 1;
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          padding: "56px 28px 40px",
          animation: "slideRight 0.3s ease",
        },
      },
      e(
        "div",
        { style: { display: "flex", gap: 4, marginBottom: 24 } },
        e("div", {
          style: { height: 3, flex: 1, background: "#FF2D8D", borderRadius: 2 },
        }),
        e("div", {
          style: { height: 3, flex: 1, background: "#A3FF12", borderRadius: 2 },
        }),
        e("div", {
          style: { height: 3, flex: 1, background: "#2C2C36", borderRadius: 2 },
        }),
      ),
      e(
        "div",
        { style: { marginBottom: 20 } },
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 11,
              fontWeight: 700,
              color: "#A3FF12",
              letterSpacing: "0.22em",
              marginBottom: 14,
            },
          },
          "02 / INTERESTS",
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 48,
              color: "#fff",
              lineHeight: 0.9,
              letterSpacing: "-0.01em",
            },
          },
          `WHAT'S`,
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 48,
              color: "#A3FF12",
              lineHeight: 0.9,
              letterSpacing: "-0.01em",
              marginBottom: 8,
            },
          },
          "YOUR VIBE?",
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 13,
              color: "#A7A7B3",
            },
          },
          "Pick your interests — we'll personalize everything.",
        ),
      ),
      e(
        "div",
        {
          style: {
            display: "flex",
            flexWrap: "wrap",
            gap: 9,
            flex: 1,
            alignContent: "flex-start",
            overflowY: "auto",
            paddingBottom: 8,
          },
        },
        ...this.INTERESTS.map((int, i) => {
          const sel = s.selInterests.has(int.id);
          const col = this.ICOLORS[i % this.ICOLORS.length];
          const dark = col === "#A3FF12" || col === "#FFD400";
          return e(
            "button",
            {
              key: int.id,
              onClick: () => {
                const ns = new Set(s.selInterests);
                ns.has(int.id) ? ns.delete(int.id) : ns.add(int.id);
                this.setState({ selInterests: ns });
              },
              style: {
                display: "flex",
                alignItems: "center",
                gap: 7,
                padding: "9px 15px",
                borderRadius: 100,
                background: sel ? col : "transparent",
                border: `2px solid ${sel ? col : "#2C2C36"}`,
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 13,
                fontWeight: 600,
                color: sel ? (dark ? "#0B0B0F" : "#fff") : "#A7A7B3",
                cursor: "pointer",
                transition: "all 0.15s",
              },
            },
            int.emoji,
            " ",
            int.label,
          );
        }),
      ),
      e(
        "button",
        {
          onClick: () => enough && this.nav("home", "home"),
          style: {
            width: "100%",
            padding: "18px",
            marginTop: 16,
            background: enough ? "#A3FF12" : "#1D1D24",
            border: "none",
            borderRadius: 16,
            fontFamily: "'Space Grotesk',sans-serif",
            fontSize: 15,
            fontWeight: 700,
            color: enough ? "#0B0B0F" : "#A7A7B3",
            cursor: enough ? "pointer" : "default",
            letterSpacing: "0.06em",
            transition: "all 0.2s",
          },
        },
        `LET'S GO →`,
      ),
    );
  }

  renderHome() {
    const e = this.e.bind(this);
    const hot = this.EVENTS.filter((ev) => ev.hot);
    const weekend = this.EVENTS.filter((ev) => ev.weekend);
    const suggested = this.COMMUNITIES.slice(0, 6);
    const newAdded = this.EVENTS.slice(4);
    const ticker = [
      "🔥 HOT THIS WEEK:",
      "TECHNORITI '25",
      "·",
      "CIRCUIT TECHNO NIGHT",
      "·",
      "OPEN MIC @ CANVAS",
      "·",
      "FARMERS MARKET",
      "·",
      "PHOTO WALK",
      "·",
      "FLOWER EXPO",
      "·",
      "STARTUP CHAI",
      "·",
    ];
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "scaleIn 0.3s ease",
        },
      },
      e(
        "div",
        {
          style: {
            height: 44,
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "0 20px",
            flexShrink: 0,
          },
        },
        e(
          "span",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 14,
              fontWeight: 600,
              color: "#fff",
            },
          },
          "9:41",
        ),
        e(
          "div",
          { style: { display: "flex", gap: 5, alignItems: "center" } },
          e(
            "svg",
            { width: 15, height: 11, viewBox: "0 0 15 11", fill: "white" },
            e("path", {
              d: "M7.5 2C5.2 2 3.1 2.9 1.5 4.4L0 2.9C2 1.1 4.6 0 7.5 0s5.5 1.1 7.5 2.9L13.5 4.4C11.9 2.9 9.8 2 7.5 2zm0 4c-1.4 0-2.7.5-3.7 1.4L2.3 5.9C3.7 4.7 5.5 4 7.5 4s3.8.7 5.2 1.9L11.2 7.4C10.2 6.5 8.9 6 7.5 6zm0 4c-.8 0-1.5.3-2 .8L7.5 13l2-2.2c-.5-.5-1.2-.8-2-.8z",
            }),
          ),
          e(
            "div",
            {
              style: {
                width: 22,
                height: 12,
                border: "1.5px solid #fff",
                borderRadius: 3,
                position: "relative",
                overflow: "hidden",
              },
            },
            e("div", {
              style: {
                position: "absolute",
                inset: "1.5px",
                background: "#fff",
                borderRadius: 1,
              },
            }),
            e("div", {
              style: {
                position: "absolute",
                right: -3,
                top: "50%",
                transform: "translateY(-50%)",
                width: 2,
                height: 5,
                background: "rgba(255,255,255,0.5)",
                borderRadius: 1,
              },
            }),
          ),
        ),
      ),
      e(
        "div",
        {
          style: {
            padding: "0 20px 12px",
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            flexShrink: 0,
          },
        },
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 38,
              color: "#fff",
              letterSpacing: "-0.02em",
              lineHeight: 1,
              animation: "glitch 6s ease-in-out infinite 2s",
            },
          },
          "HATRI",
        ),
        e(
          "div",
          { style: { display: "flex", gap: 10 } },
          e(
            "button",
            {
              onClick: () => this.nav("search", "home"),
              style: {
                width: 40,
                height: 40,
                background: "#141419",
                border: "1px solid #2C2C36",
                borderRadius: 12,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
              },
            },
            e(
              "svg",
              {
                width: 18,
                height: 18,
                viewBox: "0 0 24 24",
                fill: "none",
                stroke: "#A7A7B3",
                strokeWidth: 2,
              },
              e("circle", { cx: 11, cy: 11, r: 8 }),
              e("path", { d: "m21 21-4.35-4.35", strokeLinecap: "round" }),
            ),
          ),
          e(
            "button",
            {
              onClick: () => this.nav("notifications", "home"),
              style: {
                width: 40,
                height: 40,
                background: "#141419",
                border: "1px solid #2C2C36",
                borderRadius: 12,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
                position: "relative",
              },
            },
            e(
              "svg",
              { width: 18, height: 18, viewBox: "0 0 24 24", fill: "#A7A7B3" },
              e("path", {
                d: "M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z",
              }),
            ),
            e("div", {
              style: {
                position: "absolute",
                top: 8,
                right: 8,
                width: 8,
                height: 8,
                background: "#FF2D8D",
                borderRadius: "50%",
                border: "2px solid #0B0B0F",
              },
            }),
          ),
        ),
      ),
      e(
        "div",
        {
          style: {
            background: "#141419",
            borderTop: "1px solid #1D1D24",
            borderBottom: "1px solid #1D1D24",
            padding: "7px 0",
            overflow: "hidden",
            flexShrink: 0,
          },
        },
        e(
          "div",
          {
            style: {
              display: "inline-block",
              whiteSpace: "nowrap",
              animation: "marquee 28s linear infinite",
            },
          },
          ...[...ticker, ...ticker].map((t, i) =>
            e(
              "span",
              {
                key: i,
                style: {
                  fontFamily: "Bebas Neue,sans-serif",
                  fontSize: 13,
                  color: t.startsWith("🔥")
                    ? "#FF2D8D"
                    : t === "·"
                      ? "#2C2C36"
                      : "#A7A7B3",
                  marginRight: 14,
                  letterSpacing: "0.08em",
                },
              },
              t,
            ),
          ),
        ),
      ),
      e(
        "div",
        {
          style: {
            flex: 1,
            overflowY: "auto",
            overflowX: "hidden",
            paddingBottom: 100,
          },
        },
        this.sectionHeader("🔥 HOT IN TOWN", "#FF2D8D", () =>
          this.nav("events", "events"),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 14,
              paddingLeft: 20,
              overflowX: "auto",
              paddingBottom: 4,
              paddingRight: 8,
            },
          },
          ...hot.map((ev) => this.posterCard(ev)),
        ),
        this.sectionHeader("📅 WEEKEND PLANS", "#FFD400", () =>
          this.nav("events", "events"),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 12,
              paddingLeft: 20,
              overflowX: "auto",
              paddingBottom: 4,
              paddingRight: 8,
            },
          },
          ...weekend.slice(0, 4).map((ev) => this.smallCard(ev)),
        ),
        this.sectionHeader("👥 JOIN A COMMUNITY", "#7B2DFF", () =>
          this.nav("communities", "communities"),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 12,
              paddingLeft: 20,
              overflowX: "auto",
              paddingBottom: 4,
              paddingRight: 8,
            },
          },
          ...suggested.map((c) => this.commChip(c)),
        ),
        this.sectionHeader("✨ NEWLY ADDED", "#A3FF12", () =>
          this.nav("events", "events"),
        ),
        e(
          "div",
          { style: { padding: "0 20px" } },
          ...newAdded.map((ev) => this.listCard(ev)),
        ),
        this.sectionHeader("⭐ EDITOR'S PICK", "#2D7DFF", null),
        e(
          "div",
          { style: { padding: "0 20px 20px" } },
          e(
            "div",
            {
              onClick: () => {
                this.setState({ selEv: this.EVENTS[0] });
                this.nav("event-detail");
              },
              style: {
                borderRadius: 20,
                overflow: "hidden",
                background: this.EVENTS[0].dark,
                border: `1px solid ${this.EVENTS[0].color}30`,
                cursor: "pointer",
                padding: 22,
                position: "relative",
              },
            },
            e("div", {
              style: {
                position: "absolute",
                top: -30,
                right: -30,
                width: 180,
                height: 180,
                background: this.EVENTS[0].color,
                borderRadius: "50%",
                opacity: 0.12,
                filter: "blur(40px)",
              },
            }),
            e(
              "div",
              {
                style: {
                  display: "inline-block",
                  background: this.EVENTS[0].color,
                  borderRadius: 8,
                  padding: "4px 10px",
                  marginBottom: 14,
                },
              },
              e(
                "span",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 10,
                    fontWeight: 700,
                    color: "#fff",
                    letterSpacing: "0.1em",
                  },
                },
                "⭐ EDITOR'S PICK",
              ),
            ),
            e(
              "div",
              {
                style: {
                  fontFamily: "Anton,sans-serif",
                  fontSize: 40,
                  color: "#fff",
                  lineHeight: 0.9,
                  letterSpacing: "-0.01em",
                  marginBottom: 10,
                },
              },
              this.EVENTS[0].title,
            ),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 13,
                  color: "#A7A7B3",
                  marginBottom: 14,
                  lineHeight: 1.5,
                },
              },
              this.EVENTS[0].subtitle,
            ),
            e(
              "div",
              {
                style: {
                  display: "flex",
                  justifyContent: "space-between",
                  alignItems: "center",
                },
              },
              e(
                "div",
                {},
                e(
                  "div",
                  {
                    style: {
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 13,
                      fontWeight: 600,
                      color: "#fff",
                    },
                  },
                  this.EVENTS[0].date,
                ),
                e(
                  "div",
                  {
                    style: {
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 12,
                      color: "#A7A7B3",
                    },
                  },
                  this.EVENTS[0].venue,
                ),
              ),
              e(
                "div",
                {
                  style: {
                    width: 42,
                    height: 42,
                    background: this.EVENTS[0].color,
                    borderRadius: 12,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                  },
                },
                e(
                  "svg",
                  { width: 20, height: 20, viewBox: "0 0 24 24", fill: "#fff" },
                  e("path", {
                    d: "M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z",
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  renderEvents() {
    const e = this.e.bind(this);
    const s = this.state;
    const filters = [
      "All",
      "College Fest",
      "Music",
      "Market",
      "Nightlife",
      "Photography",
      "Startup",
      "Exhibition",
    ];
    const filterColors = {
      All: "#FF2D8D",
      "College Fest": "#2D7DFF",
      Music: "#FF2D8D",
      Market: "#A3FF12",
      Nightlife: "#7B2DFF",
      Photography: "#FF7A00",
      Startup: "#FFD400",
      Exhibition: "#FF2D8D",
    };
    const filtered =
      s.evFilter === "all"
        ? this.EVENTS
        : this.EVENTS.filter(
            (ev) => ev.category === s.evFilter || ev.tags.includes(s.evFilter),
          );
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "scaleIn 0.3s ease",
        },
      },
      e(
        "div",
        { style: { padding: "44px 20px 0", flexShrink: 0 } },
        e(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              marginBottom: 16,
            },
          },
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 42,
                color: "#fff",
                letterSpacing: "-0.01em",
                lineHeight: 1,
              },
            },
            "EVENTS",
          ),
          e(
            "button",
            {
              onClick: () => this.nav("search", "events"),
              style: {
                width: 40,
                height: 40,
                background: "#141419",
                border: "1px solid #2C2C36",
                borderRadius: 12,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
              },
            },
            e(
              "svg",
              {
                width: 18,
                height: 18,
                viewBox: "0 0 24 24",
                fill: "none",
                stroke: "#A7A7B3",
                strokeWidth: 2,
              },
              e("circle", { cx: 11, cy: 11, r: 8 }),
              e("path", { d: "m21 21-4.35-4.35", strokeLinecap: "round" }),
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 8,
              overflowX: "auto",
              paddingBottom: 16,
              paddingRight: 4,
            },
          },
          ...filters.map((f) => {
            const key = f === "All" ? "all" : f;
            const active =
              s.evFilter === key || (s.evFilter === "all" && f === "All");
            const col = filterColors[f] || "#FF2D8D";
            const dark = col === "#A3FF12" || col === "#FFD400";
            return e(
              "button",
              {
                key: f,
                onClick: () => this.setState({ evFilter: key }),
                style: {
                  flexShrink: 0,
                  padding: "7px 15px",
                  borderRadius: 100,
                  background: active ? col : "transparent",
                  border: `1.5px solid ${active ? col : "#2C2C36"}`,
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 12,
                  fontWeight: 600,
                  color: active ? (dark ? "#0B0B0F" : "#fff") : "#A7A7B3",
                  cursor: "pointer",
                  transition: "all 0.15s",
                },
              },
              f,
            );
          }),
        ),
      ),
      e(
        "div",
        {
          style: {
            flex: 1,
            overflowY: "auto",
            padding: "0 20px",
            paddingBottom: 100,
          },
        },
        e(
          "div",
          {
            style: { display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 },
          },
          ...filtered.map((ev) => this.eventGridCard(ev)),
        ),
      ),
    );
  }

  renderEventDetail() {
    const e = this.e.bind(this);
    const ev = this.state.selEv;
    if (!ev) return null;
    const rsvpd = this.state.rsvpd.has(ev.id);
    const saved = this.state.saved.has(ev.id);
    const dark = ev.color === "#A3FF12" || ev.color === "#FFD400";
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "slideRight 0.3s ease",
        },
      },
      e(
        "div",
        {
          style: {
            height: 290,
            background: ev.dark,
            position: "relative",
            flexShrink: 0,
            overflow: "hidden",
          },
        },
        e("div", {
          style: {
            position: "absolute",
            top: -40,
            right: -40,
            width: 220,
            height: 220,
            background: ev.color,
            borderRadius: "50%",
            opacity: 0.3,
            filter: "blur(60px)",
          },
        }),
        e("div", {
          style: {
            position: "absolute",
            bottom: -40,
            left: -40,
            width: 160,
            height: 160,
            background: ev.color,
            borderRadius: "50%",
            opacity: 0.15,
            filter: "blur(40px)",
          },
        }),
        e(
          "div",
          {
            style: {
              position: "absolute",
              top: 52,
              left: 16,
              display: "flex",
              gap: 10,
              zIndex: 10,
            },
          },
          this.backBtn(() => this.goBack()),
          e(
            "button",
            {
              onClick: () => this.toggleSave(ev.id),
              style: {
                width: 38,
                height: 38,
                background: "rgba(0,0,0,0.55)",
                backdropFilter: "blur(10px)",
                border: `1px solid ${saved ? ev.color : "rgba(255,255,255,0.1)"}`,
                borderRadius: 12,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
                transition: "border-color 0.2s",
              },
            },
            e(
              "svg",
              {
                width: 19,
                height: 19,
                viewBox: "0 0 24 24",
                fill: saved ? ev.color : "none",
                stroke: saved ? ev.color : "white",
                strokeWidth: 2,
              },
              e("path", {
                d: "M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z",
              }),
            ),
          ),
        ),
        e(
          "div",
          { style: { position: "absolute", bottom: 24, left: 20, right: 20 } },
          e(
            "div",
            {
              style: {
                display: "inline-block",
                background: ev.color + "28",
                border: `1px solid ${ev.color}55`,
                borderRadius: 6,
                padding: "3px 9px",
                marginBottom: 10,
              },
            },
            e(
              "span",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 10,
                  fontWeight: 700,
                  color: ev.color,
                  letterSpacing: "0.12em",
                },
              },
              ev.category.toUpperCase(),
            ),
          ),
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 44,
                color: "#fff",
                lineHeight: 0.88,
                letterSpacing: "-0.01em",
                textShadow: `0 0 50px ${ev.color}55`,
              },
            },
            ev.title,
          ),
        ),
      ),
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", padding: "20px 20px 110px" } },
        e(
          "div",
          {
            style: {
              display: "flex",
              flexWrap: "wrap",
              gap: 10,
              marginBottom: 16,
            },
          },
          ...[
            [`📅`, ev.date],
            [`⏰`, ev.time],
          ].map(([ic, tx]) =>
            e(
              "div",
              {
                key: ic,
                style: {
                  display: "inline-flex",
                  alignItems: "center",
                  gap: 8,
                  background: "#141419",
                  border: "1px solid #2C2C36",
                  borderRadius: 10,
                  padding: "8px 14px",
                },
              },
              e("span", { style: { fontSize: 14 } }, ic),
              e(
                "span",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 13,
                    fontWeight: 500,
                    color: "#fff",
                  },
                },
                tx,
              ),
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center",
              gap: 8,
              background: "#141419",
              border: "1px solid #2C2C36",
              borderRadius: 10,
              padding: "8px 14px",
              marginBottom: 20,
            },
          },
          e("span", { style: { fontSize: 14 } }, "📍"),
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 13,
                fontWeight: 500,
                color: "#fff",
              },
            },
            ev.venue,
          ),
        ),
        e("div", {
          style: { height: 1, background: "#2C2C36", marginBottom: 20 },
        }),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 12,
              alignItems: "center",
              marginBottom: 20,
            },
          },
          e(
            "div",
            {
              style: {
                width: 42,
                height: 42,
                background: ev.color + "25",
                borderRadius: 12,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                border: `1px solid ${ev.color}35`,
                fontSize: 20,
                flexShrink: 0,
              },
            },
            "🎪",
          ),
          e(
            "div",
            {},
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 10,
                  color: "#A7A7B3",
                  letterSpacing: "0.1em",
                },
              },
              "ORGANIZED BY",
            ),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 14,
                  fontWeight: 700,
                  color: "#fff",
                },
              },
              ev.organizer,
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 14,
              color: "#A7A7B3",
              lineHeight: 1.75,
              marginBottom: 20,
            },
          },
          ev.description,
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              flexWrap: "wrap",
              gap: 8,
              marginBottom: 20,
            },
          },
          ...ev.tags.map((tag) =>
            e(
              "div",
              {
                key: tag,
                style: {
                  padding: "5px 12px",
                  background: "#141419",
                  border: "1px solid #2C2C36",
                  borderRadius: 100,
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 12,
                  color: "#A7A7B3",
                },
              },
              `#${tag}`,
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center",
              gap: 8,
              padding: "13px 16px",
              background: "#141419",
              borderRadius: 14,
              border: "1px solid #2C2C36",
            },
          },
          e("div", {
            style: {
              width: 8,
              height: 8,
              background: ev.color,
              borderRadius: "50%",
              animation: "blink 2s infinite",
            },
          }),
          e(
            "span",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 14,
                fontWeight: 600,
                color: "#fff",
              },
            },
            `${ev.interested} people interested`,
          ),
        ),
      ),
      e(
        "div",
        {
          style: {
            position: "absolute",
            bottom: 0,
            left: 0,
            right: 0,
            padding: "12px 20px 32px",
            background: "rgba(11,11,15,0.97)",
            backdropFilter: "blur(20px)",
            borderTop: "1px solid #2C2C36",
          },
        },
        e(
          "button",
          {
            onClick: () => this.toggleRsvp(ev.id),
            style: {
              width: "100%",
              padding: "17px",
              background: rsvpd ? "transparent" : ev.color,
              border: `2px solid ${ev.color}`,
              borderRadius: 16,
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 14,
              fontWeight: 700,
              color: rsvpd ? ev.color : dark ? "#0B0B0F" : "#fff",
              cursor: "pointer",
              letterSpacing: "0.05em",
              transition: "all 0.2s",
            },
          },
          rsvpd ? "✓ YOU'RE GOING — CANCEL RSVP" : "📌 MARK AS INTERESTED",
        ),
      ),
    );
  }

  renderCommunities() {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "scaleIn 0.3s ease",
        },
      },
      e(
        "div",
        { style: { padding: "44px 20px 16px", flexShrink: 0 } },
        e(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              marginBottom: 6,
            },
          },
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 40,
                color: "#fff",
                letterSpacing: "-0.01em",
                lineHeight: 1,
              },
            },
            "COMMUNITY",
          ),
          e(
            "button",
            {
              onClick: () => this.nav("search", "communities"),
              style: {
                width: 40,
                height: 40,
                background: "#141419",
                border: "1px solid #2C2C36",
                borderRadius: 12,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                cursor: "pointer",
              },
            },
            e(
              "svg",
              {
                width: 18,
                height: 18,
                viewBox: "0 0 24 24",
                fill: "none",
                stroke: "#A7A7B3",
                strokeWidth: 2,
              },
              e("circle", { cx: 11, cy: 11, r: 8 }),
              e("path", { d: "m21 21-4.35-4.35", strokeLinecap: "round" }),
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 13,
              color: "#A7A7B3",
            },
          },
          "Find your people in Raipur.",
        ),
      ),
      e(
        "div",
        {
          style: {
            flex: 1,
            overflowY: "auto",
            padding: "0 20px",
            paddingBottom: 100,
          },
        },
        e(
          "div",
          {
            style: { display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 },
          },
          ...this.COMMUNITIES.map((c) => this.commCard(c)),
        ),
      ),
    );
  }

  renderCommunityDetail() {
    const e = this.e.bind(this);
    const comm = this.state.selComm;
    if (!comm) return null;
    const joined = this.state.joined.has(comm.id);
    const tab = this.state.commTab;
    const posts = this.POSTS.filter((p) => p.cid === comm.id);
    const relEvts = this.EVENTS.filter((ev) =>
      ev.tags.some(
        (t) =>
          t.toLowerCase() === comm.name.toLowerCase() ||
          comm.name.toLowerCase().includes(t.toLowerCase()),
      ),
    ).slice(0, 3);
    const dark = comm.color === "#A3FF12" || comm.color === "#FFD400";
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "slideRight 0.3s ease",
        },
      },
      e(
        "div",
        {
          style: {
            height: 180,
            background: `linear-gradient(135deg,${comm.color}35 0%,#141419 100%)`,
            borderBottom: "1px solid #2C2C36",
            position: "relative",
            flexShrink: 0,
            overflow: "hidden",
          },
        },
        e("div", {
          style: {
            position: "absolute",
            top: -30,
            right: -30,
            width: 180,
            height: 180,
            background: comm.color,
            borderRadius: "50%",
            opacity: 0.15,
            filter: "blur(35px)",
          },
        }),
        e(
          "div",
          { style: { position: "absolute", top: 52, left: 16 } },
          this.backBtn(() => this.goBack()),
        ),
        e(
          "div",
          {
            style: {
              position: "absolute",
              bottom: 16,
              left: 20,
              right: 20,
              display: "flex",
              alignItems: "flex-end",
              justifyContent: "space-between",
            },
          },
          e(
            "div",
            {},
            e("div", { style: { fontSize: 32, marginBottom: 4 } }, comm.emoji),
            e(
              "div",
              {
                style: {
                  fontFamily: "Anton,sans-serif",
                  fontSize: 28,
                  color: "#fff",
                  lineHeight: 1,
                  letterSpacing: "-0.01em",
                },
              },
              comm.name.toUpperCase(),
            ),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 12,
                  color: "#A7A7B3",
                  marginTop: 2,
                },
              },
              `${(comm.members / 1000).toFixed(1)}K members · ${comm.posts} posts`,
            ),
          ),
          e(
            "button",
            {
              onClick: (ev) => {
                ev.stopPropagation();
                this.toggleJoin(comm.id);
              },
              style: {
                padding: "9px 20px",
                borderRadius: 12,
                background: joined ? "transparent" : comm.color,
                border: `2px solid ${comm.color}`,
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 13,
                fontWeight: 700,
                color: joined ? comm.color : dark ? "#0B0B0F" : "#fff",
                cursor: "pointer",
                transition: "all 0.15s",
              },
            },
            joined ? "✓ JOINED" : "+ JOIN",
          ),
        ),
      ),
      e(
        "div",
        {
          style: {
            display: "flex",
            borderBottom: "1px solid #2C2C36",
            flexShrink: 0,
          },
        },
        ...["posts", "events", "about"].map((t) =>
          e(
            "button",
            {
              key: t,
              onClick: () => this.setState({ commTab: t }),
              style: {
                flex: 1,
                padding: "14px",
                background: "none",
                border: "none",
                borderBottom:
                  tab === t
                    ? `2px solid ${comm.color}`
                    : "2px solid transparent",
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 13,
                fontWeight: 600,
                color: tab === t ? comm.color : "#A7A7B3",
                cursor: "pointer",
                letterSpacing: "0.04em",
                transition: "color 0.15s",
              },
            },
            t.toUpperCase(),
          ),
        ),
      ),
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", paddingBottom: 100 } },
        tab === "posts" &&
          e(
            "div",
            { style: { padding: "16px 16px 0" } },
            posts.length > 0
              ? posts.map((p) => this.postCard(p, comm))
              : e(
                  "div",
                  {
                    style: {
                      textAlign: "center",
                      padding: "48px 20px",
                      color: "#A7A7B3",
                      fontFamily: "'Space Grotesk',sans-serif",
                    },
                  },
                  "No posts yet. Be the first!",
                ),
          ),
        tab === "events" &&
          e(
            "div",
            { style: { padding: "16px" } },
            relEvts.length > 0
              ? relEvts.map((ev) => this.listCard(ev))
              : e(
                  "div",
                  {
                    style: {
                      textAlign: "center",
                      padding: "48px 20px",
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 14,
                      color: "#A7A7B3",
                    },
                  },
                  "No events linked yet.",
                ),
          ),
        tab === "about" &&
          e(
            "div",
            { style: { padding: 20 } },
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 14,
                  color: "#A7A7B3",
                  lineHeight: 1.75,
                  marginBottom: 20,
                },
              },
              comm.description,
            ),
            e(
              "div",
              {
                style: {
                  background: "#141419",
                  borderRadius: 16,
                  padding: 20,
                  border: "1px solid #2C2C36",
                },
              },
              e(
                "div",
                { style: { display: "flex", justifyContent: "space-around" } },
                e(
                  "div",
                  { style: { textAlign: "center" } },
                  e(
                    "div",
                    {
                      style: {
                        fontFamily: "Anton,sans-serif",
                        fontSize: 30,
                        color: "#fff",
                      },
                    },
                    `${(comm.members / 1000).toFixed(1)}K`,
                  ),
                  e(
                    "div",
                    {
                      style: {
                        fontFamily: "'Space Grotesk',sans-serif",
                        fontSize: 10,
                        color: "#A7A7B3",
                        letterSpacing: "0.1em",
                        marginTop: 3,
                      },
                    },
                    "MEMBERS",
                  ),
                ),
                e("div", { style: { width: 1, background: "#2C2C36" } }),
                e(
                  "div",
                  { style: { textAlign: "center" } },
                  e(
                    "div",
                    {
                      style: {
                        fontFamily: "Anton,sans-serif",
                        fontSize: 30,
                        color: "#fff",
                      },
                    },
                    comm.posts,
                  ),
                  e(
                    "div",
                    {
                      style: {
                        fontFamily: "'Space Grotesk',sans-serif",
                        fontSize: 10,
                        color: "#A7A7B3",
                        letterSpacing: "0.1em",
                        marginTop: 3,
                      },
                    },
                    "POSTS",
                  ),
                ),
              ),
            ),
          ),
      ),
    );
  }

  renderCity() {
    const e = this.e.bind(this);
    const trending = this.EVENTS.filter((ev) => ev.trending);
    const featured = this.EVENTS[3];
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "scaleIn 0.3s ease",
        },
      },
      e(
        "div",
        { style: { padding: "44px 20px 16px", flexShrink: 0 } },
        e(
          "div",
          {
            style: {
              display: "flex",
              alignItems: "center",
              gap: 10,
              marginBottom: 2,
            },
          },
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 42,
                color: "#fff",
                letterSpacing: "-0.01em",
                lineHeight: 1,
              },
            },
            "CITY",
          ),
          e(
            "div",
            {
              style: {
                background: "#2D7DFF20",
                border: "1px solid #2D7DFF40",
                borderRadius: 8,
                padding: "4px 10px",
              },
            },
            e(
              "span",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 11,
                  fontWeight: 700,
                  color: "#2D7DFF",
                  letterSpacing: "0.1em",
                },
              },
              "📍 RAIPUR",
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 13,
              color: "#A7A7B3",
            },
          },
          "What's happening this week",
        ),
      ),
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", paddingBottom: 100 } },
        e(
          "div",
          { style: { margin: "0 20px 4px" } },
          e(
            "div",
            {
              onClick: () => {
                this.setState({ selEv: featured });
                this.nav("event-detail");
              },
              style: {
                borderRadius: 22,
                overflow: "hidden",
                background: featured.dark,
                border: `1px solid ${featured.color}30`,
                cursor: "pointer",
                padding: 22,
                position: "relative",
                minHeight: 190,
              },
            },
            e("div", {
              style: {
                position: "absolute",
                top: -30,
                right: -30,
                width: 180,
                height: 180,
                background: featured.color,
                borderRadius: "50%",
                opacity: 0.2,
                filter: "blur(45px)",
              },
            }),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 11,
                  fontWeight: 700,
                  color: featured.color,
                  letterSpacing: "0.16em",
                  marginBottom: 10,
                },
              },
              "🔥 TRENDING NOW",
            ),
            e(
              "div",
              {
                style: {
                  fontFamily: "Anton,sans-serif",
                  fontSize: 46,
                  color: "#fff",
                  lineHeight: 0.88,
                  letterSpacing: "-0.01em",
                  marginBottom: 12,
                },
              },
              featured.title,
            ),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 13,
                  color: "#A7A7B3",
                  marginBottom: 18,
                },
              },
              featured.subtitle,
            ),
            e(
              "div",
              { style: { display: "flex", gap: 8 } },
              e(
                "div",
                {
                  style: {
                    background: featured.color + "20",
                    border: `1px solid ${featured.color}40`,
                    borderRadius: 8,
                    padding: "6px 12px",
                  },
                },
                e(
                  "span",
                  {
                    style: {
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 12,
                      fontWeight: 600,
                      color: featured.color,
                    },
                  },
                  featured.date,
                ),
              ),
              e(
                "div",
                {
                  style: {
                    background: featured.color + "20",
                    border: `1px solid ${featured.color}40`,
                    borderRadius: 8,
                    padding: "6px 12px",
                  },
                },
                e(
                  "span",
                  {
                    style: {
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 12,
                      fontWeight: 600,
                      color: featured.color,
                    },
                  },
                  `${featured.interested} interested`,
                ),
              ),
            ),
          ),
        ),
        this.sectionHeader("🔥 HOT THIS WEEK", "#FF2D8D", () =>
          this.nav("events", "events"),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 14,
              paddingLeft: 20,
              overflowX: "auto",
              paddingBottom: 4,
              paddingRight: 8,
            },
          },
          ...trending.map((ev) => this.posterCard(ev)),
        ),
        this.sectionHeader("📅 WEEKEND PLANS", "#FFD400", () =>
          this.nav("events", "events"),
        ),
        e(
          "div",
          { style: { padding: "0 20px" } },
          ...this.EVENTS.filter((ev) => ev.weekend)
            .slice(0, 3)
            .map((ev) => this.listCard(ev)),
        ),
        this.sectionHeader("👥 POPULAR COMMUNITIES", "#7B2DFF", () =>
          this.nav("communities", "communities"),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              gap: 12,
              paddingLeft: 20,
              overflowX: "auto",
              paddingBottom: 4,
              paddingRight: 8,
            },
          },
          ...this.COMMUNITIES.slice(0, 5).map((c) => this.commChip(c)),
        ),
        this.sectionHeader("⭐ EDITOR'S PICKS", "#2D7DFF", null),
        e(
          "div",
          { style: { padding: "0 20px 20px" } },
          ...this.EVENTS.slice(4, 7).map((ev) => this.listCard(ev)),
        ),
      ),
    );
  }

  renderProfile() {
    const e = this.e.bind(this);
    const s = this.state;
    const name = s.userName || "Riya Sharma";
    const joinedComms = this.COMMUNITIES.filter((c) => s.joined.has(c.id));
    const savedEvts = this.EVENTS.filter((ev) => s.saved.has(ev.id));
    const rsvpdEvts = this.EVENTS.filter((ev) => s.rsvpd.has(ev.id));
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "scaleIn 0.3s ease",
        },
      },
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", paddingBottom: 100 } },
        e(
          "div",
          {
            style: {
              padding: "52px 20px 24px",
              background: "#141419",
              borderBottom: "1px solid #2C2C36",
            },
          },
          e(
            "div",
            {
              style: {
                display: "flex",
                alignItems: "center",
                gap: 16,
                marginBottom: 20,
              },
            },
            e(
              "div",
              {
                style: {
                  width: 64,
                  height: 64,
                  background: "linear-gradient(135deg,#FF2D8D,#7B2DFF)",
                  borderRadius: 20,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: 28,
                },
              },
              "🧑",
            ),
            e(
              "div",
              {},
              e(
                "div",
                {
                  style: {
                    fontFamily: "Anton,sans-serif",
                    fontSize: 30,
                    color: "#fff",
                    letterSpacing: "-0.01em",
                    lineHeight: 1,
                  },
                },
                name.toUpperCase(),
              ),
              e(
                "div",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 13,
                    color: "#A7A7B3",
                    marginTop: 4,
                  },
                },
                "📍 Raipur",
              ),
            ),
          ),
          e(
            "div",
            {
              style: {
                display: "grid",
                gridTemplateColumns: "1fr 1fr 1fr",
                background: "#0B0B0F",
                borderRadius: 14,
                border: "1px solid #2C2C36",
                overflow: "hidden",
              },
            },
            ...[
              ["EVENTS", rsvpdEvts.length || 3],
              ["COMMUNITIES", joinedComms.length || 2],
              ["SAVED", savedEvts.length || 1],
            ].map(([label, val], i) =>
              e(
                "div",
                {
                  key: i,
                  style: {
                    textAlign: "center",
                    padding: "14px 8px",
                    borderRight: i < 2 ? "1px solid #2C2C36" : "none",
                  },
                },
                e(
                  "div",
                  {
                    style: {
                      fontFamily: "Anton,sans-serif",
                      fontSize: 26,
                      color: "#fff",
                    },
                  },
                  val,
                ),
                e(
                  "div",
                  {
                    style: {
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 9,
                      color: "#A7A7B3",
                      letterSpacing: "0.1em",
                      marginTop: 2,
                    },
                  },
                  label,
                ),
              ),
            ),
          ),
        ),
        e(
          "div",
          { style: { padding: "20px 20px 0" } },
          e(
            "div",
            {
              style: {
                fontFamily: "Bebas Neue,sans-serif",
                fontSize: 15,
                color: "#A7A7B3",
                letterSpacing: "0.1em",
                marginBottom: 12,
              },
            },
            "YOUR INTERESTS",
          ),
          e(
            "div",
            { style: { display: "flex", flexWrap: "wrap", gap: 8 } },
            ...Array.from(s.selInterests)
              .slice(0, 8)
              .map((intId, i) => {
                const int = this.INTERESTS.find((x) => x.id === intId);
                if (!int) return null;
                const col = this.ICOLORS[i % this.ICOLORS.length];
                return e(
                  "div",
                  {
                    key: intId,
                    style: {
                      padding: "6px 14px",
                      background: col + "18",
                      border: `1px solid ${col}35`,
                      borderRadius: 100,
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 13,
                      fontWeight: 600,
                      color: col,
                    },
                  },
                  `${int.emoji} ${int.label}`,
                );
              }),
          ),
        ),
        joinedComms.length > 0 &&
          e(
            "div",
            { style: { padding: "24px 20px 0" } },
            e(
              "div",
              {
                style: {
                  fontFamily: "Bebas Neue,sans-serif",
                  fontSize: 15,
                  color: "#A7A7B3",
                  letterSpacing: "0.1em",
                  marginBottom: 12,
                },
              },
              "MY COMMUNITIES",
            ),
            e(
              "div",
              { style: { display: "flex", flexDirection: "column", gap: 8 } },
              ...joinedComms.map((c) =>
                e(
                  "div",
                  {
                    key: c.id,
                    onClick: () => {
                      this.setState({ selComm: c, commTab: "posts" });
                      this.nav("community-detail", "profile");
                    },
                    style: {
                      display: "flex",
                      alignItems: "center",
                      gap: 12,
                      background: "#141419",
                      borderRadius: 14,
                      padding: "12px 14px",
                      border: `1px solid ${c.color}30`,
                      cursor: "pointer",
                    },
                  },
                  e(
                    "div",
                    {
                      style: {
                        width: 40,
                        height: 40,
                        background: c.color + "22",
                        borderRadius: 12,
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        fontSize: 20,
                      },
                    },
                    c.emoji,
                  ),
                  e(
                    "div",
                    { style: { flex: 1 } },
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "'Space Grotesk',sans-serif",
                          fontSize: 14,
                          fontWeight: 700,
                          color: "#fff",
                        },
                      },
                      c.name,
                    ),
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "'Space Grotesk',sans-serif",
                          fontSize: 11,
                          color: "#A7A7B3",
                        },
                      },
                      `${(c.members / 1000).toFixed(1)}K members`,
                    ),
                  ),
                  e(
                    "svg",
                    {
                      width: 16,
                      height: 16,
                      viewBox: "0 0 24 24",
                      fill: "#A7A7B3",
                    },
                    e("path", {
                      d: "M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z",
                    }),
                  ),
                ),
              ),
            ),
          ),
        e(
          "div",
          { style: { padding: "24px 20px 0" } },
          e(
            "div",
            {
              style: {
                fontFamily: "Bebas Neue,sans-serif",
                fontSize: 15,
                color: "#A7A7B3",
                letterSpacing: "0.1em",
                marginBottom: 12,
              },
            },
            "SAVED EVENTS",
          ),
          savedEvts.length > 0
            ? e(
                "div",
                {},
                savedEvts.slice(0, 2).map((ev) => this.listCard(ev)),
              )
            : e(
                "div",
                {
                  style: {
                    padding: "24px",
                    background: "#141419",
                    borderRadius: 14,
                    border: "1px solid #2C2C36",
                    textAlign: "center",
                  },
                },
                e(
                  "div",
                  {
                    style: {
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 14,
                      color: "#A7A7B3",
                    },
                  },
                  "No saved events yet.",
                ),
                e(
                  "button",
                  {
                    onClick: () => this.nav("events", "profile"),
                    style: {
                      marginTop: 8,
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 13,
                      fontWeight: 600,
                      color: "#FF2D8D",
                      background: "none",
                      border: "none",
                      cursor: "pointer",
                    },
                  },
                  "Explore events →",
                ),
              ),
        ),
        e("div", {
          style: { margin: "24px 20px 0", height: 1, background: "#2C2C36" },
        }),
        e(
          "div",
          { style: { padding: "4px 20px 16px" } },
          ...["⚙️  Settings", "🔔  Notifications", "❓  Help & Support"].map(
            (item) =>
              e(
                "button",
                {
                  key: item,
                  style: {
                    display: "flex",
                    alignItems: "center",
                    width: "100%",
                    padding: "14px 0",
                    background: "none",
                    border: "none",
                    borderBottom: "1px solid #141419",
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 14,
                    color: "#fff",
                    cursor: "pointer",
                    textAlign: "left",
                  },
                },
                item,
              ),
          ),
          e(
            "button",
            {
              onClick: () =>
                this.setState({
                  screen: "splash",
                  userName: "",
                  nameInput: "",
                  selInterests: new Set(),
                  rsvpd: new Set(),
                  joined: new Set([1, 3]),
                  saved: new Set([2]),
                }),
              style: {
                display: "flex",
                alignItems: "center",
                width: "100%",
                padding: "14px 0",
                background: "none",
                border: "none",
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 14,
                color: "#FF2D8D",
                cursor: "pointer",
                textAlign: "left",
              },
            },
            "👋  Sign Out",
          ),
        ),
      ),
    );
  }

  renderNotifications() {
    const e = this.e.bind(this);
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "slideRight 0.3s ease",
        },
      },
      e(
        "div",
        {
          style: {
            padding: "52px 20px 16px",
            display: "flex",
            alignItems: "center",
            gap: 12,
            borderBottom: "1px solid #2C2C36",
            flexShrink: 0,
          },
        },
        this.backBtn(() => this.goBack()),
        e(
          "div",
          {
            style: {
              fontFamily: "Anton,sans-serif",
              fontSize: 30,
              color: "#fff",
              letterSpacing: "-0.01em",
            },
          },
          "NOTIFICATIONS",
        ),
      ),
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", padding: "8px 16px" } },
        ...this.NOTIFS.map((n) =>
          e(
            "div",
            {
              key: n.id,
              style: {
                display: "flex",
                gap: 12,
                padding: "14px 0",
                borderBottom: "1px solid #141419",
              },
            },
            e(
              "div",
              {
                style: {
                  width: 44,
                  height: 44,
                  background: n.color + "22",
                  borderRadius: 14,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: 20,
                  flexShrink: 0,
                  border: `1px solid ${n.color}30`,
                },
              },
              n.icon,
            ),
            e(
              "div",
              { style: { flex: 1 } },
              e(
                "div",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 14,
                    fontWeight: 600,
                    color: "#fff",
                    marginBottom: 2,
                  },
                },
                n.title,
              ),
              e(
                "div",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 12,
                    color: "#A7A7B3",
                    lineHeight: 1.4,
                    marginBottom: 4,
                  },
                },
                n.body,
              ),
              e(
                "div",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 11,
                    color: n.color,
                  },
                },
                n.time,
              ),
            ),
          ),
        ),
      ),
    );
  }

  renderSearch() {
    const e = this.e.bind(this);
    const s = this.state;
    const q = s.searchQ.toLowerCase();
    const results =
      q.length > 1
        ? [
            ...this.EVENTS.filter(
              (ev) =>
                ev.title.toLowerCase().includes(q) ||
                ev.category.toLowerCase().includes(q) ||
                ev.tags.some((t) => t.toLowerCase().includes(q)),
            ).map((ev) => ({ type: "event", item: ev })),
            ...this.COMMUNITIES.filter((c) =>
              c.name.toLowerCase().includes(q),
            ).map((c) => ({ type: "community", item: c })),
          ]
        : [];
    const trending = [
      "NIT Fest",
      "Open Mic",
      "Photography",
      "Techno Night",
      "Farmers Market",
      "Coffee",
      "Gaming",
      "Art",
    ];
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "slideRight 0.3s ease",
        },
      },
      e(
        "div",
        { style: { padding: "52px 16px 16px", flexShrink: 0 } },
        e(
          "div",
          { style: { display: "flex", alignItems: "center", gap: 12 } },
          this.backBtn(() => this.goBack()),
          e(
            "div",
            {
              style: {
                flex: 1,
                display: "flex",
                alignItems: "center",
                gap: 10,
                background: "#141419",
                border: "2px solid #FF2D8D",
                borderRadius: 14,
                padding: "11px 14px",
              },
            },
            e(
              "svg",
              {
                width: 18,
                height: 18,
                viewBox: "0 0 24 24",
                fill: "none",
                stroke: "#FF2D8D",
                strokeWidth: 2,
              },
              e("circle", { cx: 11, cy: 11, r: 8 }),
              e("path", { d: "m21 21-4.35-4.35", strokeLinecap: "round" }),
            ),
            e("input", {
              type: "text",
              placeholder: "Search events, communities...",
              value: s.searchQ,
              onChange: (ev) => this.setState({ searchQ: ev.target.value }),
              autoFocus: true,
              style: {
                flex: 1,
                background: "none",
                border: "none",
                outline: "none",
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 15,
                color: "#fff",
                caretColor: "#FF2D8D",
              },
            }),
          ),
        ),
      ),
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", padding: "0 16px" } },
        results.length > 0 &&
          results.map((r, i) =>
            r.type === "event"
              ? e(
                  "div",
                  {
                    key: i,
                    onClick: () => {
                      this.setState({ selEv: r.item, searchQ: "" });
                      this.nav("event-detail");
                    },
                    style: {
                      padding: "12px 0",
                      borderBottom: "1px solid #141419",
                      cursor: "pointer",
                      display: "flex",
                      alignItems: "center",
                      gap: 12,
                    },
                  },
                  e(
                    "div",
                    {
                      style: {
                        width: 44,
                        height: 44,
                        background: r.item.dark,
                        borderRadius: 12,
                        border: `1px solid ${r.item.color}40`,
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        flexShrink: 0,
                      },
                    },
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "Bebas Neue,sans-serif",
                          fontSize: 9,
                          color: r.item.color,
                          textAlign: "center",
                          lineHeight: 1.2,
                        },
                      },
                      r.item.category,
                    ),
                  ),
                  e(
                    "div",
                    {},
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "'Space Grotesk',sans-serif",
                          fontSize: 14,
                          fontWeight: 600,
                          color: "#fff",
                        },
                      },
                      r.item.title,
                    ),
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "'Space Grotesk',sans-serif",
                          fontSize: 12,
                          color: "#A7A7B3",
                        },
                      },
                      r.item.date,
                    ),
                  ),
                )
              : e(
                  "div",
                  {
                    key: i,
                    onClick: () => {
                      this.setState({
                        selComm: r.item,
                        commTab: "posts",
                        searchQ: "",
                      });
                      this.nav("community-detail");
                    },
                    style: {
                      padding: "12px 0",
                      borderBottom: "1px solid #141419",
                      cursor: "pointer",
                      display: "flex",
                      alignItems: "center",
                      gap: 12,
                    },
                  },
                  e(
                    "div",
                    {
                      style: {
                        width: 44,
                        height: 44,
                        background: r.item.color + "22",
                        borderRadius: 12,
                        border: `1px solid ${r.item.color}35`,
                        display: "flex",
                        alignItems: "center",
                        justifyContent: "center",
                        fontSize: 22,
                        flexShrink: 0,
                      },
                    },
                    r.item.emoji,
                  ),
                  e(
                    "div",
                    {},
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "'Space Grotesk',sans-serif",
                          fontSize: 14,
                          fontWeight: 600,
                          color: "#fff",
                        },
                      },
                      r.item.name,
                    ),
                    e(
                      "div",
                      {
                        style: {
                          fontFamily: "'Space Grotesk',sans-serif",
                          fontSize: 12,
                          color: "#A7A7B3",
                        },
                      },
                      `${(r.item.members / 1000).toFixed(1)}K members`,
                    ),
                  ),
                ),
          ),
        !s.searchQ &&
          e(
            "div",
            { style: { paddingTop: 8 } },
            e(
              "div",
              {
                style: {
                  fontFamily: "Bebas Neue,sans-serif",
                  fontSize: 15,
                  color: "#A7A7B3",
                  letterSpacing: "0.1em",
                  marginBottom: 14,
                  paddingTop: 8,
                },
              },
              "TRENDING SEARCHES",
            ),
            e(
              "div",
              { style: { display: "flex", flexWrap: "wrap", gap: 8 } },
              ...trending.map((q2) =>
                e(
                  "button",
                  {
                    key: q2,
                    onClick: () => this.setState({ searchQ: q2 }),
                    style: {
                      padding: "8px 15px",
                      background: "#141419",
                      border: "1px solid #2C2C36",
                      borderRadius: 100,
                      fontFamily: "'Space Grotesk',sans-serif",
                      fontSize: 13,
                      color: "#A7A7B3",
                      cursor: "pointer",
                    },
                  },
                  q2,
                ),
              ),
            ),
          ),
        results.length === 0 &&
          s.searchQ.length > 1 &&
          e(
            "div",
            { style: { padding: "60px 20px", textAlign: "center" } },
            e("div", { style: { fontSize: 40, marginBottom: 14 } }, "🔍"),
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 14,
                  color: "#A7A7B3",
                },
              },
              `No results for "${s.searchQ}"`,
            ),
          ),
      ),
    );
  }

  renderHostEvent() {
    const e = this.e.bind(this);
    const fields = [
      "Event Name",
      "Category",
      "Date & Time",
      "Venue / Location",
      "Description",
      "Organizer Name",
    ];
    return e(
      "div",
      {
        style: {
          position: "absolute",
          inset: 0,
          background: "#0B0B0F",
          display: "flex",
          flexDirection: "column",
          animation: "slideRight 0.3s ease",
        },
      },
      e(
        "div",
        {
          style: {
            padding: "52px 20px 16px",
            display: "flex",
            alignItems: "center",
            gap: 12,
            borderBottom: "1px solid #2C2C36",
            flexShrink: 0,
          },
        },
        this.backBtn(() => this.goBack()),
        e(
          "div",
          { style: { flex: 1 } },
          e(
            "div",
            {
              style: {
                fontFamily: "Anton,sans-serif",
                fontSize: 28,
                color: "#fff",
                letterSpacing: "-0.01em",
                lineHeight: 1,
              },
            },
            "HOST AN EVENT",
          ),
          e(
            "div",
            {
              style: {
                fontFamily: "'Space Grotesk',sans-serif",
                fontSize: 12,
                color: "#A7A7B3",
                marginTop: 3,
              },
            },
            "Share it with Raipur.",
          ),
        ),
      ),
      e(
        "div",
        { style: { flex: 1, overflowY: "auto", padding: "20px 20px 32px" } },
        ...fields.map((f) =>
          e(
            "div",
            { key: f, style: { marginBottom: 16 } },
            e(
              "div",
              {
                style: {
                  fontFamily: "'Space Grotesk',sans-serif",
                  fontSize: 11,
                  fontWeight: 600,
                  color: "#A7A7B3",
                  letterSpacing: "0.1em",
                  marginBottom: 8,
                },
              },
              f.toUpperCase(),
            ),
            e(
              "div",
              {
                style: {
                  background: "#141419",
                  border: "1px solid #2C2C36",
                  borderRadius: 12,
                  padding: "12px 16px",
                  minHeight: f === "Description" ? 80 : 48,
                  display: "flex",
                  alignItems: f === "Description" ? "flex-start" : "center",
                },
              },
              e(
                "span",
                {
                  style: {
                    fontFamily: "'Space Grotesk',sans-serif",
                    fontSize: 14,
                    color: "#3D3D4A",
                  },
                },
                `Enter ${f.toLowerCase()}...`,
              ),
            ),
          ),
        ),
        e(
          "div",
          {
            style: {
              display: "flex",
              flexWrap: "wrap",
              gap: 8,
              marginBottom: 24,
            },
          },
          e(
            "div",
            {
              style: {
                fontFamily: "Bebas Neue,sans-serif",
                fontSize: 14,
                color: "#A7A7B3",
                letterSpacing: "0.1em",
                width: "100%",
                marginBottom: 4,
              },
            },
            "ACCENT COLOR",
          ),
          ...[
            "#FF2D8D",
            "#A3FF12",
            "#2D7DFF",
            "#7B2DFF",
            "#FF7A00",
            "#FFD400",
          ].map((col) =>
            e("div", {
              key: col,
              style: {
                width: 36,
                height: 36,
                background: col,
                borderRadius: 10,
                cursor: "pointer",
                border: "2px solid transparent",
              },
            }),
          ),
        ),
        e(
          "button",
          {
            style: {
              width: "100%",
              padding: "18px",
              background: "linear-gradient(135deg,#FF2D8D 0%,#7B2DFF 100%)",
              border: "none",
              borderRadius: 16,
              fontFamily: "'Space Grotesk',sans-serif",
              fontSize: 15,
              fontWeight: 700,
              color: "#fff",
              cursor: "pointer",
              letterSpacing: "0.05em",
            },
          },
          "SUBMIT EVENT →",
        ),
      ),
    );
  }

  renderScreen() {
    switch (this.state.screen) {
      case "splash":
        return this.renderSplash();
      case "onboarding-name":
        return this.renderOnboardingName();
      case "onboarding-interests":
        return this.renderOnboardingInterests();
      case "home":
        return this.renderHome();
      case "events":
        return this.renderEvents();
      case "event-detail":
        return this.renderEventDetail();
      case "communities":
        return this.renderCommunities();
      case "community-detail":
        return this.renderCommunityDetail();
      case "city":
        return this.renderCity();
      case "profile":
        return this.renderProfile();
      case "notifications":
        return this.renderNotifications();
      case "search":
        return this.renderSearch();
      case "host-event":
        return this.renderHostEvent();
      default:
        return this.renderHome();
    }
  }

  renderVals() {
    const s = this.state;
    const isOnboarding = [
      "splash",
      "onboarding-name",
      "onboarding-interests",
    ].includes(s.screen);
    const isDetail = [
      "event-detail",
      "community-detail",
      "notifications",
      "search",
      "host-event",
    ].includes(s.screen);
    const tc = (tab, col) =>
      s.tab === tab && !isDetail && !isOnboarding ? col : "#A7A7B3";
    return {
      currentScreen: this.renderScreen(),
      showNav: !isOnboarding,
      showFab: !isOnboarding && !isDetail,
      homeTabColor: tc("home", "#FF2D8D"),
      eventsTabColor: tc("events", "#A3FF12"),
      communityTabColor: tc("communities", "#7B2DFF"),
      cityTabColor: tc("city", "#2D7DFF"),
      profileTabColor: tc("profile", "#FFD400"),
      goHome: () => this.nav("home", "home"),
      goEvents: () => this.nav("events", "events"),
      goCommunities: () => this.nav("communities", "communities"),
      goCity: () => this.nav("city", "city"),
      goProfile: () => this.nav("profile", "profile"),
      openHostEvent: () => this.nav("host-event"),
    };
  }
}
